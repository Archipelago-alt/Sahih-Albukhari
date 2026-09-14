# Performance

All numbers below were measured on the development machine (Linux x86_64,
Python's bundled SQLite) unless a row says otherwise. On-device numbers are
recorded only where a device run actually happened; anything not measured is
marked as such rather than estimated.

## Content database

`assets/content/bukhari_taseel.db`, importer output for Shamela book 1284:

| | Size |
|---|---|
| Database file (content schema 2) | 23,343,104 bytes (23.3 MB) |
| gzip -9 of the file (indication of compressibility) | 4,102,297 bytes (4.1 MB) |

Largest tables and indexes (SQLite `dbstat`):

| Object | Bytes | Rows |
|---|---|---|
| `hadiths` (original text, style spans, references) | 10,321,920 | 7,436 |
| `hadith_search` (normalized + broad-normalized text) | 9,809,920 | 7,436 |
| `chapters` | 1,875,968 | 4,013 |
| `heading_search` | 630,784 | 4,052 |

Content schema 2 (2026-09-14) removed the editor's footnotes: the `footnotes`
and `footnote_refs` tables and their index took 5.8 MB of the previous
29.1 MB file. The search tables are unchanged, so the search timings below
(measured with schema 1) still apply.

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

On-device search timings: **not measured yet**. To measure, run the integration test
on a device with `--profile` and read the timeline, or time
`SearchRepository.search` from a debug build.

## Reader

- A book's outline (headings and hadith ids, no text) is one query; hadith
  texts are loaded in blocks of 20 as they scroll into view.
- Positions are saved at most every 800 ms while scrolling, and on pause.

## Startup and package size

Startup was measured on an Android 35 x86_64 emulator (KVM, 4 cores, 3 GB
RAM, software rendering via SwiftShader) with the x86_64 release APK, on
2026-09-14, with `tool/bench/cold_start.sh`, using content schema 2 (23.3 MB
database). An emulator is not a phone:
physical-device numbers are still to be measured (run the same script with
`ABI=arm64-v8a DEVICE=<serial>`).

An earlier run with content schema 1 (29.1 MB database, same emulator)
measured a first frame of 1,380 ms, the home screen after about 4.0 s and a
cold-start median of 1,312 ms. Emulator timings vary between runs, so the
difference is not attributed to the smaller database alone.

| | Value |
|---|---|
| First launch after install (copies and SHA-256-checks the database) | first frame 1,031 ms (`am start -W` TotalTime); home screen visible after about 3.2 s (wall clock, polled with uiautomator at ~1 s granularity) |
| Cold start, database already installed (`am force-stop`, then `am start -W`; 5 runs) | median 838 ms (range 705–895 ms) |
| App data after first launch | 23,092 KiB (the installed database copy) |
| Debug APK (`flutter build apk --debug`, all ABIs, JIT; not representative of release size) | 187,486,212 bytes (178.8 MiB), built in 655 s on 2026-09-14 (content schema 1; not rebuilt since) |
| Release APK (`flutter build apk --release`, all three ABIs, AOT, icon fonts tree-shaken) | 68,324,605 bytes (65.2 MiB), content schema 2 (schema 1: 70,209,913 bytes) |
| Release APK, arm64-v8a only (`--split-per-abi`; what most phones download) | 26,862,565 bytes (25.6 MiB) (schema 1: 28,715,105 bytes) |
| Release APK, armeabi-v7a only | 24,402,733 bytes (23.3 MiB) |
| Release APK, x86_64 only | 28,379,833 bytes (27.1 MiB) |

Inside the debug APK (`unzip -v`, content schema 1), the content database is
stored deflated: 29,143,040 bytes → 7,879,070 bytes. In the schema-2 release
APK it is 23,343,104 bytes → 4,224,358 bytes. Most of the debug size is the Flutter
engine for three ABIs (`libflutter.so`: 40.1 MB x86_64, 38.8 MB arm64-v8a,
33.2 MB armeabi-v7a, stored uncompressed), the debug-only kernel blob
(35.5 MB compressed) and a Vulkan validation layer (15.2 MB, debug only).
`libsqlite3.so` adds about 1.7 MB per ABI.

Release validation of `app-release.apk` (`apksigner verify --print-certs`,
`aapt2 dump badging`, 2026-09-14; re-checked on the content-schema-2 build):

- The signature verifies (APK Signature Scheme v2, one signer), using the
  **Android Debug** certificate. Fine for testing; a store release needs a
  locally configured release key (see README).
- Package `io.github.archipelagoalt.sahih_albukhari`, version 1.0.0 (code 1),
  minSdk 24 (Android 7.0), targetSdk and compileSdk 36, label «صحيح البخاري»;
  native code for arm64-v8a, armeabi-v7a and x86_64.
- The only permission is the AndroidX-generated
  `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`. There is no `INTERNET`
  permission.
