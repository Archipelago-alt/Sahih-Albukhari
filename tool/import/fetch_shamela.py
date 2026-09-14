#!/usr/bin/env python3
"""Download the raw HTML pages of a Shamela book into a local cache.

The cache is the machine-readable source for the importer. Pages are stored
byte-for-byte as served (gzip-compressed on disk, which is lossless) so the
importer can be re-run deterministically without touching the network.

Usage:
    python3 tool/import/fetch_shamela.py --book 1284 --first 1 --last 4719

Re-running skips pages that are already cached and valid. The fetch is
deliberately slow (one request at a time with a delay) to be polite to
shamela.ws; see https://shamela.ws/robots.txt.
"""

from __future__ import annotations

import argparse
import gzip
import hashlib
import json
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

USER_AGENT = (
    "SahihAlbukhariReaderImporter/0.1 "
    "(+https://github.com/Archipelago-alt/Sahih-Albukhari)"
)
BASE_URL = "https://shamela.ws/book/{book}"


def page_path(out: Path, page_id: int) -> Path:
    return out / f"{page_id:05d}.html.gz"


def is_valid(raw: bytes, page_id: int | None) -> bool:
    text = raw.decode("utf-8", errors="replace")
    if page_id is None:
        return "betaka-index" in text
    return f'data-page-id="{page_id}"' in text


def fetch(url: str, retries: int = 4) -> bytes:
    delay = 5.0
    for attempt in range(1, retries + 1):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
            with urllib.request.urlopen(req, timeout=40) as resp:
                return resp.read()
        except (urllib.error.URLError, TimeoutError, ConnectionError) as exc:
            if attempt == retries:
                raise
            print(f"  retry {attempt} for {url}: {exc}", file=sys.stderr, flush=True)
            time.sleep(delay)
            delay *= 2
    raise RuntimeError("unreachable")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--book", type=int, default=1284)
    ap.add_argument("--first", type=int, default=1)
    ap.add_argument("--last", type=int, required=True)
    ap.add_argument("--out", type=Path, default=None)
    ap.add_argument("--delay", type=float, default=1.2)
    args = ap.parse_args()

    root = Path(__file__).resolve().parents[2]
    out = args.out or root / "data" / "source" / f"shamela_{args.book}" / "raw"
    out.mkdir(parents=True, exist_ok=True)
    book_url = BASE_URL.format(book=args.book)

    # The book card (bibliographic description + top-level table of contents).
    targets: list[tuple[int | None, str, Path]] = [
        (None, book_url, out / "card.html.gz")
    ]
    targets += [
        (pid, f"{book_url}/{pid}", page_path(out, pid))
        for pid in range(args.first, args.last + 1)
    ]

    fetched = skipped = 0
    for page_id, url, path in targets:
        if path.exists() and is_valid(gzip.decompress(path.read_bytes()), page_id):
            skipped += 1
            continue
        raw = fetch(url)
        if not is_valid(raw, page_id):
            print(f"ERROR: unexpected content for {url}", file=sys.stderr)
            return 2
        tmp = path.with_suffix(".tmp")
        tmp.write_bytes(gzip.compress(raw, compresslevel=9, mtime=0))
        tmp.replace(path)
        fetched += 1
        if fetched % 50 == 0:
            print(f"fetched {fetched} (last page {page_id})", flush=True)
        time.sleep(args.delay)

    manifest = {
        "book_id": args.book,
        "source_url": book_url,
        "page_range": [args.first, args.last],
        "user_agent": USER_AGENT,
        "completed_at": datetime.now(timezone.utc).isoformat(),
        "files": {
            p.name: hashlib.sha256(gzip.decompress(p.read_bytes())).hexdigest()
            for p in sorted(out.glob("*.html.gz"))
        },
    }
    (out.parent / "fetch_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=1), encoding="utf-8"
    )
    print(f"done: fetched={fetched} skipped={skipped} total={len(targets)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
