#!/usr/bin/env python3
"""Build the offline content database from the cached Shamela pages.

Pipeline (deterministic; no network access):
  1. Load every cached page (tool/import/fetch_shamela.py) and parse it.
  2. Merge the table of contents expanded on each page into one tree.
  3. Exclude the editor's introduction ("مقدمة التحقيق" subtree).
  4. Align every table-of-contents entry with its heading paragraph in the
     body text, then segment the text stream into books, chapters and
     hadiths (a hadith starts at "• [n]").
  5. Validate structure and numbering.
  6. Write the SQLite database (canonical text + separate search index),
     a canonical JSON export, provenance manifests and the import report.

The display text is Shamela's text with the editor's footnote markers
removed and the "• [n] " prefix of hadiths moved into the number field.
Nothing else is changed. The editor's footnotes are not written to the
database (owner's decision, 2026-09-14): the app contains only the original
book names, chapter names, hadith texts, numbering and references (printed
volume/page and Tuhfat al-Ashraf numbers). Markers and footnotes are still
parsed so that the report can check the source's structure.
Paragraphs that continue across a printed-page boundary are joined
with one space when the earlier page does not end in terminal punctuation;
every join is counted in the report.

Usage:
    python3 tool/import/build_database.py \
        --pdf-dir "$HOME/Downloads/Sahih ALbukhari"
"""

from __future__ import annotations

import argparse
import gzip
import hashlib
import json
import re
import sqlite3
import sys
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path

from arabic_normalize import arabic_digits_to_int, normalize
from shamela_parser import Page, Paragraph, TocNode, load_page

IMPORTER_VERSION = "1.1.0"
CONTENT_SCHEMA_VERSION = 2
BOOK_ID = 1284
INTRO_TITLE = "مقدمة التحقيق"
HEADING_RE = re.compile(r"^([٠-٩0-9]+)\s*-\s*")
SEPARATOR = "* * *"
TERMINAL = (".", "؟", "?", "!")
SHORT_RECORD = 40

ROOT = Path(__file__).resolve().parents[2]


# --------------------------------------------------------------------------
# Data structures
# --------------------------------------------------------------------------


@dataclass
class Piece:
    para: Paragraph
    page: Page
    index: int  # paragraph index on the page
    first_on_page: bool
    last_on_page: bool


@dataclass
class Joined:
    text: str = ""
    markers: list[tuple[str, int, int]] = field(default_factory=list)  # marker, offset, page
    spans: list[tuple[str, int, int]] = field(default_factory=list)
    page_joins: int = 0


def join_pieces(pieces: list[Piece]) -> Joined:
    out = Joined()
    parts: list[str] = []
    length = 0
    for i, pc in enumerate(pieces):
        if i:
            prev = pieces[i - 1]
            continues = (
                pc.first_on_page
                and prev.last_on_page
                and pc.page.page_id == prev.page.page_id + 1
                and not prev.para.text.rstrip().endswith(TERMINAL)
            )
            sep = " " if continues else "\n"
            out.page_joins += continues
            parts.append(sep)
            length += len(sep)
        out.markers += [(m, length + o, pc.page.page_id) for m, o in pc.para.markers]
        out.spans += [(c, length + s, length + e) for c, s, e in pc.para.spans]
        parts.append(pc.para.text)
        length += len(pc.para.text)
    out.text = "".join(parts)
    return out


@dataclass
class TocEntry:
    title: str
    page_id: int
    depth: int  # 1 = book, 2 = chapter, 3+ = nested chapter
    path: tuple[int, ...]  # 1-based ordinal path from the book
    parent: "TocEntry | None"
    expanded: bool


@dataclass
class Heading:
    entry: TocEntry
    piece: Piece
    number: int | None
    number_text: str | None
    title: str
    heading: str
    title_markers: list[tuple[str, int, int]]
    heading_markers: list[tuple[str, int, int]]
    preamble: list[Piece] = field(default_factory=list)
    intro: list[Piece] = field(default_factory=list)


@dataclass
class Hadith:
    number_text: str
    number: int | None
    pieces: list[Piece]
    book: Heading
    chapter: Heading | None  # None = directly under the book (no chapter heading)
    number_end: int | None = None  # set when one record carries two numbers


# --------------------------------------------------------------------------
# Table of contents
# --------------------------------------------------------------------------


def merge_toc(pages: list[Page], warnings: list[str]) -> list[dict]:
    """Merge the partially expanded TOC of every page into one tree."""
    children: dict[tuple, list[tuple]] = {}
    info: dict[tuple, TocNode] = {}

    def visit(nodes: list[TocNode], parent: tuple) -> None:
        keys = []
        for n in nodes:
            key = parent + ((n.title, n.page_id),)
            keys.append(key)
            if key not in info or info[key].children is None:
                info[key] = n
            if n.children is not None:
                visit(n.children, key)
        prev = children.get(parent)
        if prev is None:
            children[parent] = keys
        elif prev != keys:
            if len(keys) > len(prev) and keys[: len(prev)] == prev:
                children[parent] = keys
            elif not (len(prev) > len(keys) and prev[: len(keys)] == keys):
                warnings.append(f"TOC listing differs between pages under {parent[-1:]}")

    for pg in pages:
        visit(pg.toc, ())

    def build(parent: tuple) -> list[dict]:
        out = []
        for key in children.get(parent, []):
            n = info[key]
            expanded = key in children or n.children == []
            if not expanded and n.data_id is not None:
                warnings.append(f"TOC node never expanded on any page: {n.title} (page {n.page_id})")
            out.append({"title": n.title, "page_id": n.page_id, "children": build(key), "expanded": expanded})
        return out

    return build(())


def flatten_toc(tree: list[dict]) -> tuple[list[TocEntry], list[dict]]:
    """Return (entries in document order, excluded intro nodes)."""
    entries: list[TocEntry] = []
    excluded: list[dict] = []

    def walk(nodes: list[dict], depth: int, parent: TocEntry | None, path: tuple[int, ...]) -> None:
        for i, n in enumerate(nodes, start=1):
            e = TocEntry(n["title"], n["page_id"], depth, path + (i,), parent, n["expanded"])
            entries.append(e)
            walk(n["children"], depth + 1, e, e.path)

    books = []
    for n in tree:
        if n["title"] == INTRO_TITLE:
            excluded.append(n)
        else:
            books.append(n)
    for b_index, n in enumerate(books, start=1):
        e = TocEntry(n["title"], n["page_id"], 1, (b_index,), None, n["expanded"])
        entries.append(e)
        walk(n["children"], 2, e, ())
    return entries, excluded


def _words(text: str) -> list[str]:
    return normalize(HEADING_RE.sub("", text)).split()


def heading_matches(par_text: str, toc_title: str) -> str | None:
    """Return 'exact' / 'prefix' / 'lead' when the paragraph is the heading."""
    mp, mt = HEADING_RE.match(par_text), HEADING_RE.match(toc_title)
    if bool(mp) != bool(mt):
        return None
    if mp and arabic_digits_to_int(mp.group(1)) != arabic_digits_to_int(mt.group(1)):
        return None
    a, b = _words(par_text), _words(toc_title)
    if a == b:
        return "exact"
    if a[: len(b)] == b or b[: len(a)] == a:
        return "prefix"
    # Shamela's TOC sometimes runs words together ("ياأهل" for "يا أهل").
    ca, cb = "".join(a), "".join(b)
    if ca.startswith(cb) or cb.startswith(ca):
        return "compact"
    if a[:2] == b[:2] and len(b) >= 1:
        return "lead"
    # Unnumbered section headings (Tafsir surahs): the TOC says "سورة الأنفال"
    # where the body prints "الْأَنْفَالُ", or "فاتحة الكتاب" for
    # "بَابُ مَا جَاءَ فِي فَاتِحَةِ الْكِتَابِ".
    if not mt and len(a) <= 8:
        core = [w for w in b if w not in ("سورة", "سوره")]
        if core and all(w in a for w in core):
            return "contains"
    return None


def parse_hadith_number(text: str) -> tuple[int | None, int | None]:
    """'١٦' -> (16, None); '٤١٢ - ٤١٣' -> (412, 413); '٥٧٠٩ - ٥٧١٠ - ٥٧١١' -> (5709, 5711)."""
    n = arabic_digits_to_int(text)
    if n is not None:
        return n, None
    parts = [arabic_digits_to_int(p) for p in text.split("-")]
    if len(parts) > 1 and all(p is not None for p in parts):
        return parts[0], parts[-1]
    return None, None


# --------------------------------------------------------------------------
# Segmentation
# --------------------------------------------------------------------------


def is_basmala(text: str) -> bool:
    return text.strip() == "﷽" or normalize(text) == normalize("بسم الله الرحمن الرحيم")


def split_heading(piece: Piece) -> tuple[int | None, str | None, str, list, list]:
    text = piece.para.text
    markers = [(m, o, piece.page.page_id) for m, o in piece.para.markers]
    m = HEADING_RE.match(text)
    if not m:
        return None, None, text, markers, markers
    cut = m.end()
    title_markers = [(mk, max(0, o - cut), p) for mk, o, p in markers]
    return arabic_digits_to_int(m.group(1)), m.group(1), text[cut:], title_markers, markers


def segment(pages: list[Page], entries: list[TocEntry], start_page: int, report: dict):
    stream: list[Piece] = []
    for pg in pages:
        if pg.page_id < start_page:
            continue
        n = len(pg.paragraphs)
        for i, p in enumerate(pg.paragraphs):
            stream.append(Piece(p, pg, i, i == 0, i == n - 1))

    # Pass 1: align TOC entries with heading paragraphs.
    heading_at: dict[int, TocEntry] = {}
    kinds = Counter()
    mismatches, missing = [], []
    ptr = 0
    for si, pc in enumerate(stream):
        if ptr >= len(entries):
            break
        e = entries[ptr]
        if pc.page.page_id > e.page_id:
            missing.append(f"{e.title} (Shamela page {e.page_id})")
            ptr += 1
            # Re-test this paragraph against the following entry.
            while ptr < len(entries) and pc.page.page_id > entries[ptr].page_id:
                missing.append(f"{entries[ptr].title} (Shamela page {entries[ptr].page_id})")
                ptr += 1
            if ptr >= len(entries):
                break
            e = entries[ptr]
        if pc.page.page_id == e.page_id and pc.para.hadith_number is None:
            kind = heading_matches(pc.para.text, e.title)
            if kind:
                heading_at[si] = e
                kinds[kind] += 1
                if kind != "exact":
                    mismatches.append(
                        {"page": pc.page.page_id, "toc": e.title, "body": pc.para.text, "match": kind}
                    )
                ptr += 1
    missing += [f"{e.title} (Shamela page {e.page_id})" for e in entries[ptr:]]
    report["toc_alignment"] = {
        "entries": len(entries),
        "matched": len(heading_at),
        "match_kinds": dict(kinds),
        "toc_body_differences": mismatches,
        "toc_entries_not_found_in_body": missing,
    }

    # Pass 2: build books / chapters / hadiths.
    books: list[Heading] = []
    chapters: list[Heading] = []
    hadiths: list[Hadith] = []
    stack: list[Heading] = []  # headings by depth: [book, chapter, subchapter...]
    current: Hadith | None = None
    pending_preamble: list[Piece] = []
    separators, untracked_headings, bullet_without_number = [], [], []
    body_only: list[str] = []
    numbering_gaps: list[str] = []
    # Most recent numbered chapter heading (for numbering continuity), and
    # the one before an unnumbered section heading (some books continue
    # their numbering across such headings, e.g. سورة المائدة in التفسير).
    seq_anchor: Heading | None = None
    carried: Heading | None = None

    for si, pc in enumerate(stream):
        text = pc.para.text
        if si in heading_at:
            e = heading_at[si]
            number, number_text, title, title_markers, heading_markers = split_heading(pc)
            h = Heading(e, pc, number, number_text, title, text, title_markers, heading_markers)
            current = None
            stack = stack[: e.depth - 1]
            if e.depth == 1:
                h.preamble, pending_preamble = pending_preamble, []
                books.append(h)
            else:
                if len(stack) < e.depth - 1:
                    report.setdefault("errors", []).append(f"heading without parent: {text}")
                chapters.append(h)
            stack.append(h)
            if e.depth == 1:
                seq_anchor = carried = None
            elif h.number is not None:
                seq_anchor = h
            else:
                carried, seq_anchor = seq_anchor or carried, None
            continue
        if pending_preamble:
            # The basmala was not followed by a book heading: treat it as text.
            leftover, pending_preamble = pending_preamble, []
            for lp in leftover:
                _append_text(lp, current, stack)
        if text == SEPARATOR:
            separators.append(pc.page.page_id)
            continue
        if is_basmala(text) and si + 1 < len(stream) and heading_at.get(si + 1, None) is not None and heading_at[si + 1].depth == 1:
            pending_preamble.append(pc)
            continue
        if pc.para.hadith_number is not None:
            if not stack:
                report.setdefault("errors", []).append(f"hadith before first book: {pc.para.hadith_number}")
                continue
            chapter = stack[-1] if len(stack) > 1 else None
            number, number_end = parse_hadith_number(pc.para.hadith_number)
            current = Hadith(pc.para.hadith_number, number, [pc], stack[0], chapter, number_end)
            hadiths.append(current)
            continue
        if text.startswith("•"):
            bullet_without_number.append(f"page {pc.page.page_id}: {text[:60]}")
        m = HEADING_RE.match(text)
        if m and stack:
            n = arabic_digits_to_int(m.group(1))
            last_heading = stack[-1] if len(stack) > 1 else None
            if seq_anchor is not None:
                accepted, depth = {seq_anchor.number + 1}, seq_anchor.entry.depth
            elif last_heading is not None and last_heading.number is None:
                # First numbered section under an unnumbered heading (e.g. a
                # surah in كتاب التفسير): nested beneath it. The numbering
                # either restarts at 1 or continues from before the heading.
                accepted, depth = {1} | ({carried.number + 1} if carried is not None else set()), last_heading.entry.depth + 1
            else:
                accepted, depth = {1}, 2
            expected = min(accepted)
            # A single skipped number in the source is tolerated (reported).
            gap = n is not None and n not in accepted and n - 1 in accepted
            if n in accepted or gap:
                if gap:
                    numbering_gaps.append(f"page {pc.page.page_id} (printed {pc.page.printed_page}): "
                                          f"heading {m.group(1)} follows {n - 2 if n > 1 else 0}: {text[:60]}")
                # A numbered heading printed in the body but absent from
                # Shamela's table of contents. It continues the numbering
                # exactly, so it is kept as a chapter (every one is reported).
                parent_stack = stack[: depth - 1]
                parent_path = tuple(str(x) for x in parent_stack[-1].entry.path) if len(parent_stack) > 1 else ()
                path = parent_path + (f"~{n}",)
                entry = TocEntry(text, pc.page.page_id, depth, path, parent_stack[-1].entry if parent_stack else None, False)
                number, number_text, title, title_markers, heading_markers = split_heading(pc)
                h = Heading(entry, pc, number, number_text, title, text, title_markers, heading_markers)
                current = None
                stack = parent_stack + [h]
                chapters.append(h)
                seq_anchor = h
                body_only.append(f"page {pc.page.page_id} (printed {pc.page.printed_page}): {text[:90]}")
                continue
            untracked_headings.append(f"page {pc.page.page_id} (expected {expected}): {text[:80]}")
        _append_text(pc, current, stack)

    report["segmentation"] = {
        "separators_skipped": separators,
        "possible_untracked_headings": untracked_headings,
        "headings_from_body_not_in_toc": body_only,
        "heading_numbering_gaps_in_source": numbering_gaps,
        "bullet_paragraphs_without_hadith_number": bullet_without_number,
    }
    return books, chapters, hadiths


def _append_text(pc: Piece, current: Hadith | None, stack: list[Heading]) -> None:
    if current is not None:
        current.pieces.append(pc)
    elif stack:
        stack[-1].intro.append(pc)


# --------------------------------------------------------------------------
# Footnotes
# --------------------------------------------------------------------------


def collect_footnotes(pages: list[Page], start_page: int, report: dict):
    """Return {(page_id, marker): footnote_index}, footnote rows, tuhfa map."""
    rows: list[dict] = []
    index: dict[tuple[int, str], int] = {}
    tuhfa: dict[str, list[str]] = defaultdict(list)
    continuations = 0
    for pg in pages:
        if pg.page_id < start_page:
            continue
        for fn in pg.footnotes:
            if fn.marker is None:
                if rows:
                    rows[-1]["text"] += "\n" + fn.text
                    continuations += 1
                continue
            key = (pg.page_id, fn.marker)
            if key in index:
                report.setdefault("warnings", []).append(f"duplicate footnote {fn.marker} on page {pg.page_id}")
                continue
            index[key] = len(rows)
            rows.append({"page_id": pg.page_id, "marker": fn.marker, "text": fn.text})
        for number, ref in pg.tuhfa:
            tuhfa[number].append(ref)
    report["footnotes"] = {"count": len(rows), "cross_page_continuations": continuations}
    return index, rows, tuhfa


# --------------------------------------------------------------------------
# Database
# --------------------------------------------------------------------------

SCHEMA = """
PRAGMA foreign_keys = ON;
CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);
CREATE TABLE books (
  id INTEGER PRIMARY KEY,
  uid TEXT NOT NULL UNIQUE,
  sort_order INTEGER NOT NULL UNIQUE,
  number INTEGER,
  number_text TEXT,
  title TEXT NOT NULL,
  heading TEXT NOT NULL,
  preamble TEXT,
  intro TEXT,
  volume INTEGER,
  printed_page TEXT,
  source_page_id INTEGER NOT NULL,
  chapter_count INTEGER NOT NULL,
  hadith_count INTEGER NOT NULL,
  first_hadith_id INTEGER,
  last_hadith_id INTEGER
);
CREATE TABLE chapters (
  id INTEGER PRIMARY KEY,
  uid TEXT NOT NULL UNIQUE,
  book_id INTEGER NOT NULL REFERENCES books(id),
  parent_id INTEGER REFERENCES chapters(id),
  depth INTEGER NOT NULL,
  sort_order INTEGER NOT NULL UNIQUE,
  is_implicit INTEGER NOT NULL DEFAULT 0,
  number INTEGER,
  number_text TEXT,
  title TEXT,
  heading TEXT,
  intro TEXT,
  volume INTEGER,
  printed_page TEXT,
  source_page_id INTEGER,
  hadith_count INTEGER NOT NULL,
  first_hadith_id INTEGER,
  last_hadith_id INTEGER
);
CREATE INDEX chapters_book ON chapters(book_id, sort_order);
CREATE TABLE hadiths (
  id INTEGER PRIMARY KEY,
  uid TEXT NOT NULL UNIQUE,
  sort_order INTEGER NOT NULL UNIQUE,
  book_id INTEGER NOT NULL REFERENCES books(id),
  chapter_id INTEGER NOT NULL REFERENCES chapters(id),
  number INTEGER,
  number_end INTEGER,
  number_text TEXT NOT NULL,
  text TEXT NOT NULL,
  spans TEXT NOT NULL,
  volume INTEGER,
  printed_page_start TEXT,
  printed_page_end TEXT,
  source_page_start INTEGER NOT NULL,
  source_page_end INTEGER NOT NULL,
  tuhfa TEXT
);
CREATE INDEX hadiths_chapter ON hadiths(chapter_id, sort_order);
CREATE INDEX hadiths_book ON hadiths(book_id, sort_order);
CREATE INDEX hadiths_number ON hadiths(number);
-- Search-only normalized text (tool/import/arabic_normalize.py). Never displayed.
CREATE TABLE hadith_search (
  id INTEGER PRIMARY KEY REFERENCES hadiths(id),
  norm TEXT NOT NULL,
  norm_broad TEXT NOT NULL
);
CREATE TABLE heading_search (
  id INTEGER PRIMARY KEY,
  kind TEXT NOT NULL CHECK (kind IN ('book','chapter')),
  ref_id INTEGER NOT NULL,
  book_id INTEGER NOT NULL REFERENCES books(id),
  norm TEXT NOT NULL,
  norm_broad TEXT NOT NULL
);
"""


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def build(args: argparse.Namespace) -> int:
    raw_dir: Path = args.raw
    report: dict = {"importer_version": IMPORTER_VERSION, "warnings": [], "errors": []}
    page_files = sorted(raw_dir.glob("[0-9]*.html.gz"))
    if not page_files:
        print(f"no cached pages in {raw_dir}", file=sys.stderr)
        return 2
    pages = [load_page(p) for p in page_files]
    ids = [p.page_id for p in pages]
    expected = list(range(1, max(ids) + 1))
    if ids != expected:
        report["errors"].append(f"cached pages are not contiguous: missing {sorted(set(expected) - set(ids))[:20]}")
    unknown = sorted({c for p in pages for para in p.paragraphs for c in para.unknown_classes})
    if unknown:
        report["warnings"].append(f"unknown inline markup: {unknown}")

    tree = merge_toc(pages, report["warnings"])
    entries, excluded = flatten_toc(tree)
    start_page = min(e.page_id for e in entries if e.depth == 1)

    def titles(nodes: list[dict]) -> list[str]:
        out = []
        for n in nodes:
            out.append(n["title"])
            out += ["  " + t for t in titles(n["children"])]
        return out

    kept = [(p.page_id, t, q) for p in pages if p.page_id >= start_page for t, q in p.kept_numeric]
    report["numeric_parentheticals_kept_as_text"] = {
        "inside_quran_quotation": [f"page {pid}: {t}" for pid, t, q in kept if q],
        "outside_quran_quotation": [f"page {pid}: {t}" for pid, t, q in kept if not q],
    }
    report["stray_hadith_number_markup"] = [
        f"page {p.page_id} (printed {p.printed_page}): {t}" for p in pages if p.page_id >= start_page for t in p.stray_c4
    ]
    report["embedded_markers_in_text"] = [
        f"page {p.page_id} (printed {p.printed_page}): {t}"
        for p in pages
        if p.page_id >= start_page
        for t in p.embedded_markers
    ]

    intro_pages = [p for p in pages if p.page_id < start_page]
    report["excluded"] = {
        "reason": "Editor's introduction (مقدمة التحقيق) and front matter; not part of al-Bukhari's text.",
        "shamela_pages": [1, start_page - 1],
        "printed_pages": [intro_pages[0].printed_page, intro_pages[-1].printed_page] if intro_pages else [],
        "volume": intro_pages[0].volume if intro_pages else None,
        "headings": titles(excluded),
    }

    books, chapters, hadiths = segment(pages, entries, start_page, report)
    fn_index, fn_rows, tuhfa = collect_footnotes(pages, start_page, report)

    # ---------------- validation ----------------
    numbers = [h.number for h in hadiths]
    counts = Counter(h.number_text for h in hadiths)
    repeated = sorted((n for n, c in counts.items() if c > 1), key=lambda t: arabic_digits_to_int(t) or 0)
    spans = [(h.number, h.number_end or h.number) for h in hadiths if h.number is not None]
    covered = {n for a, b in spans for n in range(a, b + 1)}
    gaps = sorted(set(range(1, max(covered) + 1)) - covered) if covered else []
    order_breaks = [(p, q) for p, q in zip(spans, spans[1:]) if q[0] <= p[1]]
    ranged = [h.number_text for h in hadiths if h.number_end is not None]
    book_numbers = [b.number for b in books]

    # ---------------- write database ----------------
    out_db: Path = args.db
    out_db.parent.mkdir(parents=True, exist_ok=True)
    if out_db.exists():
        out_db.unlink()
    con = sqlite3.connect(out_db)
    con.executescript(SCHEMA)

    # Footnote markers are resolved against their page's footnotes only for the
    # report; neither markers nor footnotes are stored (see module docstring).
    marker_refs: list[tuple[str, int, int, str, int | None]] = []
    unresolved_markers: list[str] = []
    used_footnotes: set[int] = set()

    def add_markers(owner_type: str, owner_id: int, markers) -> None:
        for marker, offset, page_id in markers:
            fid = fn_index.get((page_id, marker))
            if fid is None:
                unresolved_markers.append(f"{owner_type} {owner_id}: {marker} on page {page_id}")
            else:
                used_footnotes.add(fid)
            marker_refs.append((owner_type, owner_id, offset, marker, None if fid is None else fid + 1))

    chapter_rows: list[dict] = []
    book_ids: dict[int, int] = {}
    chapter_ids: dict[int, int] = {}  # id(Heading) -> row id
    implicit: dict[int, int] = {}  # book row id -> implicit chapter row id
    chapter_sort = 0
    uid_seen: set[str] = set()

    def unique_uid(base: str) -> str:
        uid, n = base, 1
        while uid in uid_seen:
            n += 1
            uid = f"{base}-{n}"
        if uid != base:
            report["warnings"].append(f"uid collision resolved: {base} -> {uid}")
        uid_seen.add(uid)
        return uid

    for b_sort, b in enumerate(books, start=1):
        bid = b_sort
        book_ids[id(b)] = bid
        preamble = join_pieces(b.preamble) if b.preamble else None
        intro = join_pieces(b.intro) if b.intro else None
        con.execute(
            "INSERT INTO books VALUES (?,?,?,?,?,?,?,?,?,?,?,?,0,0,NULL,NULL)",
            (
                bid, unique_uid(f"b{b.number if b.number is not None else 'x' + str(b_sort)}"),
                b_sort, b.number, b.number_text, b.title, b.heading,
                preamble.text if preamble else None, intro.text if intro else None,
                b.piece.page.volume, b.piece.page.printed_page, b.piece.page.page_id,
            ),
        )
        add_markers("book_title", bid, b.title_markers)
        if preamble:
            add_markers("book_preamble", bid, preamble.markers)
        if intro:
            add_markers("book_intro", bid, intro.markers)

    def implicit_chapter(book: Heading) -> int:
        """Container for hadiths printed under a book before any chapter heading."""
        nonlocal chapter_sort
        bid = book_ids[id(book)]
        if bid not in implicit:
            chapter_sort += 1
            implicit[bid] = chapter_sort
            bnum = book.number if book.number is not None else "x"
            con.execute(
                "INSERT INTO chapters VALUES (?,?,?,NULL,1,?,1,NULL,NULL,NULL,NULL,NULL,?,?,?,0,NULL,NULL)",
                (chapter_sort, unique_uid(f"b{bnum}-c0"), bid, chapter_sort,
                 book.piece.page.volume, book.piece.page.printed_page, book.piece.page.page_id),
            )
        return implicit[bid]

    # Such hadiths precede the book's first chapter heading, so the implicit
    # container is placed immediately after the book heading.
    needs_implicit = {id(h.book) for h in hadiths if h.chapter is None}

    # Walk books and chapters in document order to assign parents.
    cur_book = None
    order = sorted([(b.piece.page.page_id, b.piece.index, "b", b) for b in books] +
                   [(c.piece.page.page_id, c.piece.index, "c", c) for c in chapters],
                   key=lambda t: (t[0], t[1]))
    parents: list[Heading] = []
    for _, _, kind, h in order:
        if kind == "b":
            cur_book = h
            parents = [h]
            if id(h) in needs_implicit:
                implicit_chapter(h)
            continue
        parents = parents[: h.entry.depth - 1]
        chapter_sort += 1
        cid = chapter_sort
        chapter_ids[id(h)] = cid
        parent_id = chapter_ids.get(id(parents[-1])) if len(parents) > 1 else None
        bnum = cur_book.number if cur_book.number is not None else "x"
        intro = join_pieces(h.intro) if h.intro else None
        con.execute(
            "INSERT INTO chapters VALUES (?,?,?,?,?,?,0,?,?,?,?,?,?,?,?,0,NULL,NULL)",
            (
                cid, unique_uid(f"b{bnum}-c{'.'.join(map(str, h.entry.path))}"),
                book_ids[id(cur_book)], parent_id, h.entry.depth - 1, cid,
                h.number, h.number_text, h.title, h.heading, intro.text if intro else None,
                h.piece.page.volume, h.piece.page.printed_page, h.piece.page.page_id,
            ),
        )
        add_markers("chapter_title", cid, h.title_markers)
        if intro:
            add_markers("chapter_intro", cid, intro.markers)
        parents.append(h)

    total_joins = 0
    short_records, empty_text = [], []
    canonical_hadiths = []
    for h_sort, h in enumerate(hadiths, start=1):
        j = join_pieces(h.pieces)
        total_joins += j.page_joins
        bid = book_ids[id(h.book)]
        cid = chapter_ids[id(h.chapter)] if h.chapter is not None else implicit_chapter(h.book)
        if h.number is None:
            base_uid = f"h{h.number_text}"
        else:
            base_uid = f"h{h.number}" + (f"-{h.number_end}" if h.number_end is not None else "")
        uid = unique_uid(base_uid)
        first, last = h.pieces[0].page, h.pieces[-1].page
        refs = tuhfa.get(h.number_text, [])
        con.execute(
            "INSERT INTO hadiths VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (
                h_sort, uid, h_sort, bid, cid, h.number, h.number_end, h.number_text, j.text,
                json.dumps(j.spans, ensure_ascii=False), first.volume, first.printed_page,
                last.printed_page, first.page_id, last.page_id, "\n".join(refs) if refs else None,
            ),
        )
        add_markers("hadith", h_sort, j.markers)
        con.execute(
            "INSERT INTO hadith_search(id, norm, norm_broad) VALUES (?,?,?)",
            (h_sort, normalize(j.text), normalize(j.text, broad=True)),
        )
        if not j.text.strip():
            empty_text.append(uid)
        elif len(j.text) < SHORT_RECORD:
            short_records.append(f"{uid}: {j.text}")
        canonical_hadiths.append(
            {
                "uid": uid, "number_text": h.number_text, "book": h.book.heading,
                "chapter": h.chapter.heading if h.chapter else None, "text": j.text,
                "source_paragraphs": [p.para.source for p in h.pieces],
                "shamela_pages": [first.page_id, last.page_id],
                "printed_pages": [first.printed_page, last.printed_page], "volume": first.volume,
            }
        )

    # Aggregates.
    con.executescript(
        """
        UPDATE chapters SET hadith_count = (SELECT COUNT(*) FROM hadiths h WHERE h.chapter_id = chapters.id),
          first_hadith_id = (SELECT MIN(id) FROM hadiths h WHERE h.chapter_id = chapters.id),
          last_hadith_id = (SELECT MAX(id) FROM hadiths h WHERE h.chapter_id = chapters.id);
        UPDATE books SET hadith_count = (SELECT COUNT(*) FROM hadiths h WHERE h.book_id = books.id),
          chapter_count = (SELECT COUNT(*) FROM chapters c WHERE c.book_id = books.id AND c.is_implicit = 0),
          first_hadith_id = (SELECT MIN(id) FROM hadiths h WHERE h.book_id = books.id),
          last_hadith_id = (SELECT MAX(id) FROM hadiths h WHERE h.book_id = books.id);
        """
    )
    for kind, sql in (
        ("book", "SELECT id, id, title FROM books ORDER BY sort_order"),
        ("chapter", "SELECT id, book_id, title FROM chapters WHERE title IS NOT NULL ORDER BY sort_order"),
    ):
        for rid, bid, title in con.execute(sql).fetchall():
            con.execute(
                "INSERT INTO heading_search(kind, ref_id, book_id, norm, norm_broad) VALUES (?,?,?,?,?)",
                (kind, rid, bid, normalize(title), normalize(title, broad=True)),
            )

    # Structural validation from the database itself.
    q = lambda sql: [r for r in con.execute(sql)]
    empty_book_names = q("SELECT uid FROM books WHERE trim(title) = ''")
    empty_chapter_names = q("SELECT uid, heading FROM chapters WHERE is_implicit = 0 AND trim(title) = ''")
    chapters_without_hadith = q(
        "SELECT c.uid, c.heading FROM chapters c WHERE c.hadith_count = 0 ORDER BY c.sort_order"
    )
    implicit_rows = q(
        "SELECT b.heading, c.hadith_count FROM chapters c JOIN books b ON b.id = c.book_id WHERE c.is_implicit = 1"
    )
    unused_footnotes = [fn_rows[i] for i in range(len(fn_rows)) if i not in used_footnotes]

    total_markers = len(marker_refs)
    stats = {
        "books": len(books),
        "chapters": len(chapters),
        "implicit_chapters": len(implicit),
        "hadith_records": len(hadiths),
        "source_footnotes_not_included": len(fn_rows),
        "source_footnote_markers_removed": total_markers,
        "page_boundary_joins": total_joins,
        "hadith_records_with_two_numbers": len(ranged),
        "first_hadith_number": hadiths[0].number_text if hadiths else None,
        "last_hadith_number": hadiths[-1].number_text if hadiths else None,
    }
    report["totals"] = stats
    report["checks"] = {
        "empty_book_names": empty_book_names,
        "empty_chapter_names": empty_chapter_names,
        "chapters_with_no_hadiths": chapters_without_hadith,
        "hadiths_without_chapter_heading": [f"{b}: {n} hadith(s)" for b, n in implicit_rows],
        "empty_hadith_text": empty_text,
        "suspiciously_short_records": short_records,
        "repeated_source_numbers": repeated,
        "missing_numbers_in_sequence": gaps,
        "numbering_order_breaks": order_breaks,
        "hadiths_without_number": [h.number_text for h in hadiths if h.number is None],
        "hadith_records_with_two_numbers": ranged,
        "book_numbers_sequential": book_numbers == list(range(1, len(books) + 1)),
        "book_numbers": book_numbers,
        "unresolved_footnote_markers": unresolved_markers,
        "unreferenced_footnotes": [f"page {r['page_id']} {r['marker']}" for r in unused_footnotes],
        "duplicate_internal_ids": [],  # enforced by UNIQUE constraints above
    }

    card = gzip.decompress((raw_dir / "card.html.gz").read_bytes()).decode("utf-8")
    card_text = re.sub(r"<[^>]+>", "\n", card.split('class="betaka-index"')[0])
    card_fields = {}
    for key in ("الكتاب", "المؤلف", "طبعة", "الناشر", "الطبعة", "عدد الأجزاء"):
        m = re.search(rf"{key}:\s*([^\n<]+)", card_text)
        if m:
            card_fields[key] = m.group(1).strip()

    fetch_manifest = raw_dir.parent / "fetch_manifest.json"
    content_manifest = {
        str(p.page_id): hashlib.sha256(p.nass_html.encode("utf-8")).hexdigest() for p in pages
    }
    content_manifest_path = raw_dir.parent / "content_manifest.json"
    content_manifest_path.write_text(json.dumps(content_manifest, indent=0), encoding="utf-8")

    meta = {
        "content_schema_version": str(CONTENT_SCHEMA_VERSION),
        "importer_version": IMPORTER_VERSION,
        "source_name": "المكتبة الشاملة",
        "source_url": f"https://shamela.ws/book/{BOOK_ID}",
        "source_book_id": str(BOOK_ID),
        "source_card": json.dumps(card_fields, ensure_ascii=False),
        "source_pages": str(len(pages)),
        "source_content_sha256": hashlib.sha256(
            json.dumps(content_manifest, sort_keys=True).encode()
        ).hexdigest(),
        "built_at": datetime.now(timezone.utc).strftime("%Y-%m-%d"),
    }
    con.executemany("INSERT INTO meta VALUES (?,?)", sorted(meta.items()))
    con.execute(f"PRAGMA user_version = {CONTENT_SCHEMA_VERSION}")
    con.commit()
    con.execute("VACUUM")
    con.close()

    # ---------------- provenance + report ----------------
    pdfs = {}
    if args.pdf_dir and args.pdf_dir.exists():
        for pdf in sorted(args.pdf_dir.glob("*.pdf")):
            pdfs[pdf.name] = sha256_file(pdf)
    report["sources"] = {
        "shamela": {
            "url": meta["source_url"],
            "card": card_fields,
            "cached_pages": len(pages),
            "fetch_manifest_sha256": sha256_file(fetch_manifest) if fetch_manifest.exists() else None,
            "content_sha256": meta["source_content_sha256"],
        },
        "pdf_sha256": pdfs,
    }
    db_path = out_db.resolve()
    report["database"] = {
        "path": str(db_path.relative_to(ROOT)) if db_path.is_relative_to(ROOT) else str(db_path),
        "sha256": sha256_file(out_db),
        "bytes": out_db.stat().st_size,
    }
    # Read by the app to decide whether the installed copy must be replaced.
    out_db.with_name("content_version.json").write_text(
        json.dumps(
            {
                "sha256": report["database"]["sha256"],
                "content_schema_version": CONTENT_SCHEMA_VERSION,
                "importer_version": IMPORTER_VERSION,
                "hadith_records": stats["hadith_records"],
            },
            indent=1,
        ),
        encoding="utf-8",
    )

    gen = args.generated
    gen.mkdir(parents=True, exist_ok=True)
    (gen / "bukhari_taseel.json").write_text(
        json.dumps({"meta": meta, "hadiths": canonical_hadiths}, ensure_ascii=False, indent=1),
        encoding="utf-8",
    )
    (gen / "import_report.json").write_text(json.dumps(report, ensure_ascii=False, indent=1), encoding="utf-8")
    write_vectors(canonical_hadiths, books, chapters)
    write_markdown_report(report, out_db)
    print(json.dumps(stats, ensure_ascii=False))
    print(f"errors={len(report['errors'])} warnings={len(report['warnings'])}")
    return 1 if report["errors"] else 0


def write_vectors(hadiths: list[dict], books: list[Heading], chapters: list[Heading]) -> None:
    """Normalization test vectors from real source text (checked by Dart tests)."""
    samples = [b.title for b in books[:10]] + [c.title for c in chapters[:20]]
    samples += [h["text"][:160] for h in hadiths[:30]]
    vectors = [{"input": s, "normalized": normalize(s), "broad": normalize(s, broad=True)} for s in samples]
    (ROOT / "tool" / "import" / "normalization_vectors.json").write_text(
        json.dumps(vectors, ensure_ascii=False, indent=1), encoding="utf-8"
    )


def _lst(items, limit: int = 60) -> str:
    items = list(items)
    if not items:
        return "_None._\n"
    lines = [f"- {i}" for i in items[:limit]]
    if len(items) > limit:
        lines.append(f"- … and {len(items) - limit} more (see `data/generated/import_report.json`)")
    return "\n".join(lines) + "\n"


def write_markdown_report(report: dict, db_path: Path) -> None:
    con = sqlite3.connect(db_path)
    t = report["totals"]
    c = report["checks"]
    s = report["sources"]
    lines = [
        "# Import validation report",
        "",
        f"Generated by `tool/import/build_database.py` v{report['importer_version']}.",
        "Regenerate with the commands in [docs/IMPORT.md](IMPORT.md).",
        "",
        "## Sources",
        "",
        f"- Machine-readable text: Al-Maktaba Al-Shamela, <{s['shamela']['url']}> "
        f"({s['shamela']['cached_pages']} cached pages).",
    ]
    for k, v in s["shamela"]["card"].items():
        lines.append(f"  - {k}: {v}")
    lines += [
        f"- Shamela page-content SHA-256 (over `content_manifest.json`): `{s['shamela']['content_sha256']}`",
        f"- Fetch manifest SHA-256: `{s['shamela']['fetch_manifest_sha256']}`",
        "- Visual verification PDFs (unchanged, SHA-256):",
    ]
    lines += [f"  - `{name}`: `{h}`" for name, h in s["pdf_sha256"].items()]
    lines += [
        "",
        "## Generated database",
        "",
        f"- `{report['database']['path']}` — {report['database']['bytes']:,} bytes",
        f"- SHA-256: `{report['database']['sha256']}`",
        "",
        "## Excluded material",
        "",
        f"- {report['excluded']['reason']}",
        f"- Shamela pages {report['excluded']['shamela_pages'][0]}–{report['excluded']['shamela_pages'][1]}"
        f" (volume {report['excluded']['volume']}, printed pages "
        f"{'–'.join(report['excluded']['printed_pages'])}).",
        f"- Ornamental separators (`* * *`) skipped on Shamela pages: "
        f"{', '.join(map(str, report['segmentation']['separators_skipped'])) or 'none'}.",
        "- Excluded headings:",
        "",
        "```",
        *report["excluded"]["headings"],
        "```",
        "",
        "## Totals",
        "",
        f"- Books: **{t['books']}**",
        f"- Chapters (with a heading in the source): **{t['chapters']}**",
        f"- Hadith records: **{t['hadith_records']}** (numbers {t['first_hadith_number']} → {t['last_hadith_number']})",
        f"- Books whose hadiths are not under any chapter heading: {t['implicit_chapters']}",
        f"- Editor footnotes in the source (not included in the app): {t['source_footnotes_not_included']}; "
        f"footnote markers removed from the text: {t['source_footnote_markers_removed']}",
        f"- Paragraphs joined across a printed-page boundary: {t['page_boundary_joins']}",
        "",
        "## Checks",
        "",
        "### Table of contents ↔ body headings",
        "",
        f"- TOC entries: {report['toc_alignment']['entries']}; matched to a body heading: "
        f"{report['toc_alignment']['matched']}; match kinds: {report['toc_alignment']['match_kinds']}",
        "",
        "TOC entries not found in the body:",
        "",
        _lst(report["toc_alignment"]["toc_entries_not_found_in_body"]),
        "Headings whose body wording differs from the TOC wording (body text is used, unchanged):",
        "",
        _lst(f"page {m['page']}: TOC «{m['toc']}» — body «{m['body']}» ({m['match']})"
             for m in report["toc_alignment"]["toc_body_differences"]),
        "Chapter headings printed in the body but missing from Shamela's table of contents "
        "(kept as chapters because they continue the chapter numbering exactly):",
        "",
        _lst(report["segmentation"]["headings_from_body_not_in_toc"]),
        "Numbering gaps in the source's headings (a number is skipped; the heading is kept):",
        "",
        _lst(report["segmentation"]["heading_numbering_gaps_in_source"]),
        "Paragraphs that look like headings but are not in the TOC (kept as text):",
        "",
        _lst(report["segmentation"]["possible_untracked_headings"]),
        "### Records",
        "",
        f"- Empty book names: {len(c['empty_book_names'])}",
        f"- Empty chapter names: {len(c['empty_chapter_names'])}",
        f"- Empty hadith text: {len(c['empty_hadith_text'])}",
        f"- Book numbers sequential 1…{t['books']}: {c['book_numbers_sequential']}",
        f"- Duplicate internal IDs: none (enforced by UNIQUE constraints)",
        "",
        "Chapters with no hadith directly beneath them (structure preserved):",
        "",
        _lst(f"{u}: {h}" for u, h in c["chapters_with_no_hadiths"]),
        "Hadiths not under a chapter heading (placed directly under their book, as in the source):",
        "",
        _lst(c["hadiths_without_chapter_heading"]),
        "Suspiciously short records (< 40 characters; kept unchanged):",
        "",
        _lst(c["suspiciously_short_records"]),
        "Repeated source hadith numbers:",
        "",
        _lst(c["repeated_source_numbers"]),
        f"Records that carry two hadith numbers (one text printed under e.g. [٤١٢ - ٤١٣]): "
        f"{len(c['hadith_records_with_two_numbers'])}",
        "",
        "Missing numbers in the hadith sequence (after counting both numbers of such records):",
        "",
        _lst(c["missing_numbers_in_sequence"]),
        "Numbering order breaks (a number smaller than the previous one):",
        "",
        _lst(c["numbering_order_breaks"]),
        "Paragraphs starting with a bullet but without a hadith number:",
        "",
        _lst(report["segmentation"]["bullet_paragraphs_without_hadith_number"]),
        "Source check — footnote markers without a footnote on the same page:",
        "",
        _lst(c["unresolved_footnote_markers"]),
        "Source check — footnotes never referenced by a marker:",
        "",
        _lst(c["unreferenced_footnotes"]),
        "Numbers in parentheses kept as text because they are not footnote markers "
        f"(inside a Quran quotation — normally ayah numbers: "
        f"{len(report['numeric_parentheticals_kept_as_text']['inside_quran_quotation'])}; "
        "outside a Quran quotation, listed for review):",
        "",
        _lst(report["numeric_parentheticals_kept_as_text"]["outside_quran_quotation"]),
        "Source markup irregularities — a footnote number typed inside parenthetical text "
        "(kept verbatim, shown as text; needs a decision):",
        "",
        _lst(report["embedded_markers_in_text"]),
        "Bracketed text marked up like a hadith number inside a paragraph (kept verbatim as text):",
        "",
        _lst(report["stray_hadith_number_markup"]),
        "### Errors and warnings",
        "",
        _lst(report["errors"]),
        _lst(report["warnings"]),
        "## Full-text vs PDF comparison",
        "",
        "See [docs/VERIFICATION.md](VERIFICATION.md).",
        "",
        "## Hadith count per chapter",
        "",
        "| Book | Chapter | Hadiths |",
        "|---|---|---|",
    ]
    for bnum, bt, cnum, ct, n in con.execute(
        """SELECT b.number_text, b.title, c.number_text, COALESCE(c.title, '—'), c.hadith_count
           FROM chapters c JOIN books b ON b.id = c.book_id ORDER BY c.sort_order"""
    ):
        lines.append(f"| {bnum} {bt} | {cnum or ''} {ct} | {n} |")
    con.close()
    (ROOT / "docs").mkdir(exist_ok=True)
    (ROOT / "docs" / "IMPORT_REPORT.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--raw", type=Path, default=ROOT / "data" / "source" / f"shamela_{BOOK_ID}" / "raw")
    ap.add_argument("--db", type=Path, default=ROOT / "assets" / "content" / "bukhari_taseel.db")
    ap.add_argument("--generated", type=Path, default=ROOT / "data" / "generated")
    ap.add_argument("--pdf-dir", type=Path, default=None)
    return build(ap.parse_args())


if __name__ == "__main__":
    sys.exit(main())
