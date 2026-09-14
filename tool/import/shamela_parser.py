"""Parse one cached Shamela reader page into structured, untouched text.

Each Shamela page corresponds to one printed page. A page contains:
  * ``div.nass`` with ``data-page-id`` / ``data-page-num`` holding ``<p>``
    paragraphs of the book text, followed by ``<hr><p class="hamesh">`` with
    the editor's footnotes;
  * the side navigation (``div.s-nav``) with the table of contents expanded
    along the current path;
  * the volume number in ``input#fld_part_bottom``.

Inline markup inside paragraphs:
  span.c2       EITHER an editor footnote marker "(٣)", OR text in
                parentheses (a variant reading, an ayah number inside a
                Quran quotation, ...). See ``MarkerState`` for how the two
                are told apart. Markers are recorded, not displayed; text is
                kept (with its range recorded as style "c2").
  span.c4       hadith number, e.g. "[١٦]"            -> recorded as metadata
  span.c1/.c5   emphasis used by the print (bold)     -> kept, range recorded
  span.special  honorific ligatures (ﷺ ﵁ ﷿ ﷽)       -> kept verbatim
  a.btn_tag, span.anchor                               -> site UI, ignored

Two strings are produced per paragraph:
  source  every visible character exactly as Shamela shows it (markers and
          hadith number included), for audit;
  text    the display text: ``source`` minus footnote markers (and the one
          space Shamela places next to each marker) and minus the leading
          "• [n] " of a hadith paragraph. No other character is changed.
"""

from __future__ import annotations

import gzip
import re
from dataclasses import dataclass, field
from pathlib import Path

from lxml import html as lxml_html

from arabic_normalize import arabic_digits_to_int

STYLE_CLASSES = {"c1", "c3", "c5"}
MARKER_RE = re.compile(r"^\(\s*([٠-٩0-9]+)\s*\)$")
EMBEDDED_MARKER_RE = re.compile(r"\(\s*[٠-٩0-9]+\s*\)")
FOOTNOTE_RE = re.compile(r"^\(([٠-٩0-9]+)\)\s?")
TUHFA_RE = re.compile(r"^\*\s*\[([٠-٩0-9]+[^\]]*)\]\s*(\[التحفة.*)$")


@dataclass
class Paragraph:
    source: str
    text: str
    markers: list[tuple[str, int]] = field(default_factory=list)  # (marker, offset in text)
    spans: list[tuple[str, int, int]] = field(default_factory=list)  # (class, start, end)
    hadith_number: str | None = None  # contents of span.c4 without brackets
    unknown_classes: set[str] = field(default_factory=set)


@dataclass
class Footnote:
    marker: str | None  # None = continuation of a footnote from the previous page
    text: str


@dataclass
class TocNode:
    title: str
    page_id: int
    data_id: str | None
    children: list["TocNode"] | None  # None = not expanded on this page


@dataclass
class MarkerState:
    """Decides, per page, whether a numeric ``span.c2`` is a footnote marker.

    Footnote markers on a printed page appear in increasing order of first
    use (a footnote may be referenced again later). A numeric parenthetical
    is therefore a marker only when a footnote with that number exists on
    the page AND it is either a repeat of a marker already used or exactly
    the next number in sequence. Anything else (typically an ayah number
    inside a Quran quotation) is kept as text and listed in the report.
    """

    available: set[int]
    used: set[int] = field(default_factory=set)
    last: int = 0
    kept_numeric: list[tuple[str, bool]] = field(default_factory=list)  # (text, inside ﴿﴾)
    # Parenthetical text that itself contains a "(n)": a marker Shamela typed
    # as plain text. Kept verbatim and reported; never repaired.
    embedded_markers: list[str] = field(default_factory=list)
    # Bracketed text styled like a hadith number but not at the start of a
    # paragraph (e.g. "[الطور: ١، ٢]"): kept verbatim as text and reported.
    stray_c4: list[str] = field(default_factory=list)

    def note_embedded(self, marker: str) -> None:
        """A marker typed as plain text still occupies its place in the
        sequence, so later markers on the page are recognised."""
        m = MARKER_RE.match(marker)
        v = arabic_digits_to_int(m.group(1)) if m else None
        if v is not None and v in self.available and v == self.last + 1:
            self.used.add(v)
            self.last = v

    def is_marker(self, content: str) -> bool:
        m = MARKER_RE.match(content)
        if not m:
            return False
        v = arabic_digits_to_int(m.group(1))
        if v is None or v not in self.available:
            return False
        if v in self.used:
            return True
        if v == self.last + 1:
            self.used.add(v)
            self.last = v
            return True
        return False


@dataclass
class Page:
    page_id: int
    printed_page: str
    volume: int | None
    paragraphs: list[Paragraph]
    footnotes: list[Footnote]
    tuhfa: list[tuple[str, str]]  # (hadith number text, reference text)
    toc: list[TocNode]
    nass_html: str
    kept_numeric: list[tuple[str, bool]]
    embedded_markers: list[str]
    stray_c4: list[str]


class _TextBuilder:
    def __init__(self, state: MarkerState) -> None:
        self.state = state
        self.src: list[str] = []
        self.txt: list[str] = []
        self.drop_next_space = False
        self.p = Paragraph(source="", text="")

    @property
    def offset(self) -> int:
        return sum(len(s) for s in self.txt)

    def in_quran(self) -> bool:
        so_far = "".join(self.txt)
        return so_far.count("﴿") > so_far.count("﴾")

    def emit(self, s: str, *, display: bool = True) -> None:
        if not s:
            return
        self.src.append(s)
        if not display:
            return
        if self.drop_next_space and s.startswith(" "):
            s = s[1:]
        if s:
            self.drop_next_space = False
        self.txt.append(s)

    def marker(self, marker: str) -> None:
        self.src.append(marker)
        # Remove the single space Shamela puts between a word and its marker.
        if self.txt and self.txt[-1].endswith(" "):
            self.txt[-1] = self.txt[-1][:-1]
        else:
            self.drop_next_space = True
        self.p.markers.append((marker, self.offset))

    def walk(self, node) -> None:
        self.emit(node.text or "")
        for child in node:
            cls = set((child.get("class") or "").split())
            if child.tag == "a" and "btn_tag" in cls:
                pass
            elif child.tag == "span" and "anchor" in cls:
                pass
            elif child.tag == "span" and "c2" in cls:
                content = child.text_content()
                if len(child) == 0 and self.state.is_marker(content):
                    self.marker(content)
                else:
                    if MARKER_RE.match(content):
                        self.state.kept_numeric.append((content, self.in_quran()))
                    elif EMBEDDED_MARKER_RE.search(content):
                        self.state.embedded_markers.append(content)
                        for found in EMBEDDED_MARKER_RE.findall(content):
                            self.state.note_embedded(found)
                    start = self.offset
                    self.walk(child)
                    self.p.spans.append(("c2", start, self.offset))
            elif child.tag == "span" and "c4" in cls:
                number = child.text_content()
                if self.p.hadith_number is None and "".join(self.txt).strip() in ("", "•"):
                    self.emit(number, display=False)
                    self.p.hadith_number = number.strip().strip("[]").strip()
                else:
                    self.state.stray_c4.append(number)
                    start = self.offset
                    self.walk(child)
                    self.p.spans.append(("c4", start, self.offset))
            elif child.tag == "span" and cls & STYLE_CLASSES:
                start = self.offset
                self.walk(child)
                self.p.spans.append((sorted(cls & STYLE_CLASSES)[0], start, self.offset))
            elif child.tag == "span" and "special" in cls:
                self.walk(child)
            elif child.tag == "br":
                self.emit("\n")
            else:
                self.p.unknown_classes.add(f"{child.tag}.{'.'.join(sorted(cls))}")
                self.walk(child)
            self.emit(child.tail or "")


def _paragraph(el, state: MarkerState) -> Paragraph:
    b = _TextBuilder(state)
    b.walk(el)
    p = b.p
    source = "".join(b.src)
    text = "".join(b.txt)
    # Trim surrounding whitespace introduced by the HTML layout, keeping
    # marker/span offsets consistent with the trimmed display text.
    lead = len(text) - len(text.lstrip())
    text = text.strip()
    if p.hadith_number is not None and text.startswith("•"):
        # Hadith paragraphs start with "• [n] "; the number is kept as metadata.
        cut = 1 + (len(text) - 1 - len(text[1:].lstrip()))
        lead += cut
        text = text[cut:]
    p.markers = [(m, max(0, o - lead)) for m, o in p.markers]
    p.spans = [(c, max(0, s - lead), max(0, e - lead)) for c, s, e in p.spans]
    p.source = source.strip()
    p.text = text
    return p


def _footnotes(el) -> tuple[list[Footnote], list[tuple[str, str]]]:
    lines: list[str] = [el.text or ""]
    for child in el:
        if child.tag == "br":
            lines.append(child.tail or "")
        else:
            lines[-1] += child.text_content() + (child.tail or "")
    notes: list[Footnote] = []
    tuhfa: list[tuple[str, str]] = []
    for raw in lines:
        line = raw.strip()
        if not line:
            continue
        m = TUHFA_RE.match(line)
        if m:
            tuhfa.append((m.group(1).strip(), m.group(2).strip()))
            continue
        m = FOOTNOTE_RE.match(line)
        if m:
            notes.append(Footnote(marker=f"({m.group(1)})", text=line[m.end():]))
        elif notes:
            notes[-1].text += "\n" + line
        else:
            notes.append(Footnote(marker=None, text=line))
    return notes, tuhfa


def _toc(ul) -> list[TocNode]:
    nodes: list[TocNode] = []
    for li in ul.findall("li"):
        exp = li.find("a[@data-id]")
        link = [a for a in li.findall("a") if (a.get("href") or "").startswith("https://shamela.ws/book/")]
        if not link:
            continue
        page_id = int(link[0].get("href").rstrip("/").split("/")[-1].split("#")[0])
        sub = li.find("ul")
        nodes.append(
            TocNode(
                title=link[0].text_content().strip(),
                page_id=page_id,
                data_id=exp.get("data-id") if exp is not None else None,
                children=_toc(sub) if sub is not None else ([] if exp is None else None),
            )
        )
    return nodes


def parse_page_html(raw: str) -> Page:
    doc = lxml_html.fromstring(raw)
    nass = doc.xpath('//div[contains(concat(" ", @class, " "), " nass ")]')
    if len(nass) != 1:
        raise ValueError(f"expected one div.nass, found {len(nass)}")
    nass = nass[0]
    vol = doc.xpath('//input[@id="fld_part_bottom"]/@value')
    nav = doc.xpath('//div[@class="s-nav"]/ul')

    footnotes: list[Footnote] = []
    tuhfa: list[tuple[str, str]] = []
    for el in nass:
        if el.tag == "p" and "hamesh" in (el.get("class") or ""):
            f, t = _footnotes(el)
            footnotes += f
            tuhfa += t
    available = {
        v for v in (arabic_digits_to_int(f.marker.strip("()")) for f in footnotes if f.marker) if v is not None
    }
    state = MarkerState(available)

    paragraphs: list[Paragraph] = []
    for el in nass:
        if el.tag == "hr" or (el.tag == "p" and "hamesh" in (el.get("class") or "")):
            continue
        if el.tag != "p":
            raise ValueError(f"unexpected element <{el.tag}> in div.nass")
        paragraphs.append(_paragraph(el, state))
    return Page(
        page_id=int(nass.get("data-page-id")),
        printed_page=nass.get("data-page-num") or "",
        volume=int(vol[0]) if vol and vol[0].isdigit() else None,
        paragraphs=paragraphs,
        footnotes=footnotes,
        tuhfa=tuhfa,
        toc=_toc(nav[0]) if nav else [],
        nass_html=lxml_html.tostring(nass, encoding="unicode"),
        kept_numeric=state.kept_numeric,
        embedded_markers=state.embedded_markers,
        stray_c4=state.stray_c4,
    )


def load_page(path: Path) -> Page:
    return parse_page_html(gzip.decompress(path.read_bytes()).decode("utf-8"))
