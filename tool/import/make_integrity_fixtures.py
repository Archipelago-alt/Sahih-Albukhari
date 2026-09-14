#!/usr/bin/env python3
"""Extract representative records from the raw Shamela pages with a small,
independent implementation (regular expressions only, no shared code with
the importer) and write them as test fixtures.

The integrity tests (test/integrity/) compare the generated database with
these fixtures character by character. Two independent extractions agreeing
is evidence that the importer neither drops nor alters characters.

Usage: python3 tool/import/make_integrity_fixtures.py
"""

from __future__ import annotations

import gzip
import html
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "data" / "source" / "shamela_1284" / "raw"
OUT = ROOT / "test" / "integrity" / "fixtures.json"

# Hadith numbers spread over the whole book (first/last, long, multi-page,
# repeated narrations, near book boundaries) and headings to check.
HADITHS = ["١", "٢", "١٥", "١٦", "١٧", "١٢٩", "٢٣٧", "١٠٠٠", "٢٥٠٠", "٣٠٠٠", "٤٤٧٥",
           "٥٠٠٠", "٥٧٨٣", "٥٩٧٣", "٦٠٠٠", "٧٠٠٠", "٧٥٥٩"]

DIGITS = str.maketrans("٠١٢٣٤٥٦٧٨٩", "0123456789")


def nass(pid: int) -> tuple[str, str]:
    raw = gzip.decompress((RAW / f"{pid:05d}.html.gz").read_bytes()).decode("utf-8")
    m = re.search(r'<div class="nass[^"]*" data-page-id="\d+" data-page-num="([^"]*)">(.*?)<hr>|'
                  r'<div class="nass[^"]*" data-page-id="\d+" data-page-num="([^"]*)">(.*?)</div>', raw, re.S)
    body = m.group(2) if m.group(2) is not None else m.group(4)
    return body, (m.group(1) or m.group(3))


def footnote_numbers(pid: int) -> set[str]:
    raw = gzip.decompress((RAW / f"{pid:05d}.html.gz").read_bytes()).decode("utf-8")
    m = re.search(r'<p class="hamesh">(.*?)</p>', raw, re.S)
    if not m:
        return set()
    return set(re.findall(r'(?:^|<br />)\s*\(([٠-٩]+)\)', m.group(1)))


def paragraphs(pid: int) -> list[str]:
    body, _ = nass(pid)
    return re.findall(r"<p>(.*?)</p>", body, re.S)


def plain(par: str) -> str:
    par = re.sub(r'<a href="#p\d+" class="btn_tag[^>]*>.*?</a>', "", par, flags=re.S)
    par = re.sub(r'<span (?:id="p\d+" )?class="anchor"(?: id="p\d+")?></span>', "", par)
    return html.unescape(re.sub(r"<[^>]+>", "", par)).strip()


def find_hadith(number: str, last_page: int) -> tuple[int, int]:
    needle = f'<span class="c4">[{number}]</span>'
    for pid in range(153, last_page + 1):
        if needle in gzip.decompress((RAW / f"{pid:05d}.html.gz").read_bytes()).decode("utf-8"):
            return pid, 0
    raise SystemExit(f"hadith {number} not found")


def main() -> None:
    last = max(int(p.name[:5]) for p in RAW.glob("[0-9]*.html.gz"))
    fixtures = []
    for number in HADITHS:
        pid, _ = find_hadith(number, last)
        pars_html: list[tuple[int, str]] = []
        started = False
        page = pid
        done = False
        while page <= last and not done:
            for p in paragraphs(page):
                is_start = '<span class="c4">[' in p
                if started and (is_start or re.match(r"^[٠-٩]+ - ", plain(p)) or plain(p) == "* * *"):
                    done = True
                    break
                if f'<span class="c4">[{number}]</span>' in p:
                    started = True
                if started:
                    pars_html.append((page, p))
            page += 1
        # Independent marker removal: a numeric (n) in span.c2 that has a
        # footnote on its page is a marker; remove it with one adjacent space.
        texts = []
        for page_id, p in pars_html:
            notes = footnote_numbers(page_id)

            def strip_marker(m: re.Match) -> str:
                return "\x01" if m.group(1) in notes else m.group(0)

            s = re.sub(r'<span class="c2">\(([٠-٩]+)\)</span>', strip_marker, p)
            s = plain(s)
            s = s.replace(" \x01", "").replace("\x01 ", "").replace("\x01", "")
            texts.append((page_id, s))
        first = re.sub(r"^•\s*\[[^\]]+\]\s*", "", texts[0][1])
        joined = first
        for (prev_pid, prev), (pid2, cur) in zip(texts, texts[1:]):
            sep = " " if pid2 == prev_pid + 1 and not prev.rstrip().endswith((".", "؟", "?", "!")) else "\n"
            joined += sep + cur
        fixtures.append({"number_text": number, "number": int(number.translate(DIGITS)),
                         "shamela_pages": [texts[0][0], texts[-1][0]], "text": joined})
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps({"source": "https://shamela.ws/book/1284", "hadiths": fixtures},
                              ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"wrote {len(fixtures)} fixtures to {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
