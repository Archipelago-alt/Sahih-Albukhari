#!/usr/bin/env python3
"""Benchmark the app's search SQL against the generated content database.

Runs exactly the queries SearchRepository issues (instr() over the
normalized search columns) for common and uncommon Arabic words, and prints
median timings. This measures SQLite on the development machine; on-device
timings are recorded separately in docs/PERFORMANCE.md.

Usage: python3 tool/bench/search_bench.py [path/to/bukhari_taseel.db]
"""

from __future__ import annotations

import sqlite3
import statistics
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "import"))
from arabic_normalize import normalize  # noqa: E402

DB = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parents[2] / "assets/content/bukhari_taseel.db"

QUERIES = [
    ("common word", "allWords", "رسول الله"),
    ("common word", "allWords", "قال"),
    ("phrase", "phrase", "انما الاعمال بالنيات"),
    ("uncommon word", "allWords", "التلبينة"),
    ("two words", "allWords", "حلاوة الايمان"),
    ("rare word", "allWords", "الذريرة"),
]


def run(con: sqlite3.Connection, mode: str, query: str, whole: bool, page: int = 20) -> tuple[int, float, float]:
    tokens = normalize(query).split() if mode == "allWords" else [normalize(query)]
    col = "s.norm"
    if whole:
        where = " AND ".join([f"instr(' ' || {col} || ' ', ?) > 0"] * len(tokens))
        args = [f" {t} " for t in tokens]
    else:
        where = " AND ".join([f"instr({col}, ?) > 0"] * len(tokens))
        args = tokens
    count_sql = f"SELECT COUNT(*) FROM hadiths h JOIN hadith_search s ON s.id = h.id WHERE {where}"
    page_sql = (f"SELECT h.id FROM hadiths h JOIN hadith_search s ON s.id = h.id WHERE {where} "
                f"ORDER BY h.sort_order LIMIT {page} OFFSET 0")
    t0 = time.perf_counter()
    n = con.execute(count_sql, args).fetchone()[0]
    t1 = time.perf_counter()
    con.execute(page_sql, args).fetchall()
    t2 = time.perf_counter()
    return n, (t1 - t0) * 1000, (t2 - t1) * 1000


def main() -> None:
    con = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    print(f"database: {DB} ({DB.stat().st_size / 1e6:.1f} MB)")
    print(f"{'kind':14} {'query':24} {'whole':5} {'hits':>6} {'count ms':>9} {'page ms':>8}")
    for kind, mode, q in QUERIES:
        for whole in (False, True):
            runs = [run(con, mode, q, whole) for _ in range(7)]
            n = runs[0][0]
            c = statistics.median(r[1] for r in runs)
            p = statistics.median(r[2] for r in runs)
            print(f"{kind:14} {q:24} {str(whole):5} {n:6d} {c:9.1f} {p:8.1f}")


if __name__ == "__main__":
    main()
