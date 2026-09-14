# Performance

All numbers below were measured on the development machine (Linux x86_64,
Python's bundled SQLite) unless a row says otherwise. On-device numbers are
recorded only where a device run actually happened; anything not measured is
marked as such rather than estimated.

## Content database

`assets/content/bukhari_taseel.db`, importer output for Shamela book 1284:

| | Size |
|---|---|
| Database file | 29,143,040 bytes (29.1 MB) |
| gzip -9 of the file (indication of compressibility) | 5,851,360 bytes (5.9 MB) |

Largest tables and indexes (SQLite `dbstat`):

| Object | Bytes | Rows |
|---|---|---|
| `hadiths` (original text, style spans, references) | 10,321,920 | 7,436 |
| `hadith_search` (normalized + broad-normalized text) | 9,809,920 | 7,436 |
| `footnotes` | 3,612,672 | 31,493 |
| `chapters` | 1,875,968 | 4,013 |
| `footnote_refs` + `footnote_refs_owner` index | 991,232 + 712,704 | 32,834 |
| `heading_search` | 630,784 | 4,052 |

The search columns roughly double the text size. That is the price of
matching inside words and with diacritics removed without touching the
displayed text (see README, "Why SQLite").

## Search

`python3 tool/bench/search_bench.py` runs the same SQL that
`SearchRepository` issues (`instr()` over the normalized columns). Median of
repeated runs; *count* is the total-hits query, *page* the first page of 20
results with snippets' source rows.

| Kind | Query | Whole word | Hits | Count (ms) | Page (ms) |
|---|---|---|---|---|---|
| common word | رسول الله | no | 3,565 | 16.0 | 0.1 |
| common word | رسول الله | yes | 3,425 | 12.2 | 0.1 |
| common word | قال | no | 7,048 | 5.4 | 0.0 |
| common word | قال | yes | 6,486 | 6.4 | 0.0 |
| phrase | انما الاعمال بالنيات | no | 1 | 15.4 | 15.4 |
| phrase | انما الاعمال بالنيات | yes | 1 | 10.8 | 11.2 |
| uncommon word | التلبينة | no | 3 | 15.5 | 16.0 |
| uncommon word | التلبينة | yes | 2 | 11.7 | 12.0 |
| two words | حلاوة الايمان | no | 4 | 16.9 | 16.9 |
| two words | حلاوة الايمان | yes | 4 | 11.9 | 12.1 |
| rare word | الذريرة | no | 0 | 16.7 | 16.1 |
| rare word | الذريرة | yes | 0 | 11.3 | 11.3 |

Every query is a full scan of ~10 MB of normalized text, so the worst case
is bounded and does not depend on how common the word is. In the app the
query runs on drift's background isolate, so the UI thread never waits on
it; the search field is debounced and results are paged.

On-device search timings: **not measured yet** (no device or emulator was
available in the build environment). To measure, run the integration test
on a device with `--profile` and read the timeline, or time
`SearchRepository.search` from a debug build.

## Reader

- A book's outline (headings and hadith ids, no text) is one query; hadith
  texts are loaded in blocks of 20 as they scroll into view.
- Positions are saved at most every 800 ms while scrolling, and on pause.

## Startup and package size

| | Value |
|---|---|
| First launch: copy + SHA-256 check of the 29 MB database | not measured on a device yet |
| Cold start | not measured on a device yet |
| Debug APK | pending (build in progress) |
| Release APK | pending |
