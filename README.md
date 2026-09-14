# صحيح البخاري — Sahih al-Bukhari Reader

An offline, Arabic-first Flutter reader for the complete *Sahih al-Bukhari*
(الجامع المسند الصحيح), built so that the text shown is exactly the source
text — never rewritten, normalized or "corrected".

<p align="center"><img src="docs/images/icon_mask_preview.png" alt="App icon under launcher masks" width="640"></p>

> Screenshots are in [`docs/images/`](docs/images/). See
> [docs/VERIFICATION.md](docs/VERIFICATION.md) for how the text was checked
> against the printed edition.

## Features

- Books → chapters → hadiths, in the source's order, with every chapter
  heading shown before the hadiths the source places beneath it.
- Continuous reader with a table of contents, previous/next hadith and
  chapter, jump to a hadith number, current book/chapter indicator,
  selectable text, adjustable font, line height and margins, light / sepia /
  dark / system themes, optional keep-screen-awake.
- The edition editor's footnotes and Tuhfat al-Ashraf references, clearly
  separated from the text as «حواشي المحقق» (markers can be hidden).
- Search: all words, exact phrase, exact-with-diacritics; normalized Arabic
  (diacritics, tatweel, alef forms, alif maqṣūra, digits; optional ة/ه
  folding); whole-word option; hadith-number search; book and chapter name
  search; book/chapter filters; highlighted snippets; pagination; recent
  searches. Results open inside the correct book and chapter, scrolled to
  the match.
- Bookmarks with folders, labels, sorting; private notes with search; reading
  history, automatic progress, per-book and overall progress; exact
  reading-position restore.
- JSON backup/restore (versioned, validated, confirmation before replacing).
- Arabic and English interface, full RTL, large text and screen-reader
  support. No account, network, ads or analytics.

## Platforms and versions

- Android 7.0 (API 24) or newer, targeting API 36 — the primary platform.
  iOS and tablets use the same code base; iOS is not built here.
- Flutter **3.47.4** (stable), Dart **3.13.3** — see `pubspec.yaml`.

## Getting started

```bash
git clone https://github.com/Archipelago-alt/Sahih-Albukhari.git
cd Sahih-Albukhari
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n

# The book data is generated locally (not in Git — see Licensing):
python3 tool/import/fetch_shamela.py --book 1284 --first 1 --last 4719
python3 tool/import/build_database.py --pdf-dir /path/to/verification/pdfs

flutter run
```

### Development commands

| Task | Command |
|---|---|
| Format | `dart format --line-length 120 lib test integration_test` |
| Analyze | `flutter analyze` |
| Unit, database, widget, integrity tests | `flutter test` |
| Integration test (device/emulator) | `flutter test integration_test/app_flow_test.dart` |
| App icons | `python3 tool/icon/generate_icon.py && dart run flutter_launcher_icons` |
| Search benchmark | `python3 tool/bench/search_bench.py` |
| Android debug / release | `flutter build apk --debug` / `flutter build apk --release` |

Release builds are currently signed with the debug key
(`android/app/build.gradle.kts`), which is fine for testing but not for a
store. Before publishing, add a release signing config locally;
`android/key.properties`, `*.jks` and `*.keystore` are gitignored and must
never be committed.

## Architecture

Feature-based, Riverpod for state, drift/SQLite for storage.

```
lib/
  app/            app widget, router (go_router), theme, providers
  core/arabic/    search-only Arabic normalizer (+ digit helpers)
  data/content/   read-only content DB, repository, search, installer
  data/user/      user DB (drift): bookmarks, notes, progress, history, settings
  features/       home, books, chapters, reader, search, bookmarks, notes,
                  progress, backup, settings
  l10n/           ARB files (ar = template, en)
  shared/         common widgets and helpers
tool/import/      Shamela fetcher, parser, database builder, fixtures
tool/icon/        icon generator
```

- **Two databases.** The canonical content database is bundled as an asset,
  copied on first launch and verified by SHA-256, then opened read-only on a
  background isolate. User data lives in a separate drift database and
  refers to hadiths by stable uids (`h16`), so content updates never touch
  it.
- **Lazy reader.** A book's outline (headings + hadith ids) is loaded first;
  hadith texts are fetched in blocks of 20 as they scroll into view and
  released afterwards.

### Why SQLite (drift + sqlite3, which bundles SQLite through native build hooks)

Arabic search needs substring matching (Arabic attaches و ف ب ك ل ال to
words) and exact matching with diacritics; SQLite's `instr()` over a
precomputed, search-only normalized column does both, offline, on a
background isolate, fast enough for the whole collection (see
docs/PERFORMANCE.md). SQLite gives transactional user data, versioned
migrations (drift), a small footprint and mature tooling. FTS5 token indexes
were rejected because they cannot match inside words, and trigram indexes
because they cannot match two-letter words and inflate the database.

## Data model and import

See [docs/IMPORT.md](docs/IMPORT.md) (workflow, schema, identifiers) and
[docs/IMPORT_REPORT.md](docs/IMPORT_REPORT.md) (latest validation report).

- Source text: Al-Maktaba Al-Shamela, book 1284 — *Sahih al-Bukhari, Dar
  al-Ta'seel edition* (1st ed. 1433 AH / 2012), revised against the
  Sultaniyya edition.
- Verification: the owner's scanned PDFs of the printed edition (image-only;
  used by eye, never OCR'd).
- **Excluded:** the editor's introduction (مقدمة التحقيق — biography of
  al-Bukhari, the riwayat, the Yunini and Sultaniyya editions, the
  introductions of Ahmad Shakir, al-Shaykh Hassuna and the Sultaniyya
  correctors), front matter and ornamental separators. The printed tables of
  contents are not part of the Shamela text.
- Content rules: [docs/CONTENT_INTEGRITY.md](docs/CONTENT_INTEGRITY.md).

Imported content (from the latest import report):

| | |
|---|---|
| Books | 95 |
| Chapters with a heading in the source | 3,957 (341 of them present only in the body, not in Shamela's table of contents) |
| Books whose hadiths are not under any chapter heading | 56 |
| Hadith records | 7,436 — numbers ١ to ٧٥٥٩, none missing (118 records are printed under two numbers) |
| Editor footnotes / markers | 31,493 / 32,834 |
| Importer errors / warnings | 0 / 0 |

## Search and Arabic normalization

Normalization (identical in `tool/import/arabic_normalize.py` and
`lib/core/arabic/arabic_normalizer.dart`, tested against shared vectors):

1. remove harakat, shadda, sukun, tanween, dagger alif, Quranic marks, tatweel;
2. أ إ آ ٱ → ا; ى → ي; Arabic-Indic digits → 0–9;
3. optional (setting): ة → ه;
4. punctuation → word separator.

It is applied only to the hidden search columns and to the query. Displayed,
copied, shared and exported text is always the original.

## Testing

`flutter test` runs unit tests (normalization, search, highlighting, spans,
share text, progress, settings, backup validation), database tests (user
schema and persistence, content structure, ordering, relationships, search
filters, pagination), integrity tests (records compared character by
character with an independent extraction of the source) and widget tests
(RTL, headings, chapter/hadith placement, reader settings, search
highlighting, bookmarks, empty/error states, large text). 81 tests; all
passed on 2026-09-14 with Flutter 3.47.4.

`integration_test/app_flow_test.dart` (open → search → open result →
bookmark → note → backup) needs a device or emulator.

Search timings and database size: [docs/PERFORMANCE.md](docs/PERFORMANCE.md).

## Licensing

- **Code:** MIT — see [LICENSE](LICENSE).
- **Book data:** *not* covered by the code licence; the edition is
  copyrighted by its publisher. The generated database is not committed.
  **A licensing decision by the project owner is required before public
  distribution** — see [docs/DATA_LICENSE.md](docs/DATA_LICENSE.md).
- **Fonts:** Amiri, Noto Naskh Arabic, Noto Sans Arabic — SIL OFL 1.1
  (licence files in `assets/fonts/`).

## Known limitations

- Only representative records were compared with the printed edition by
  eye; see "Known limitations" and "Decisions needed" in
  [docs/VERIFICATION.md](docs/VERIFICATION.md).
- The book data may not be redistributed until the licensing decision in
  [docs/DATA_LICENSE.md](docs/DATA_LICENSE.md) is made; the database is
  built locally by the importer.
- iOS is not built or tested in this environment.
- No on-device performance numbers yet (see docs/PERFORMANCE.md).

## Privacy

The app has no network permission, no accounts, no analytics and no ads.
Bookmarks, notes, progress, history and settings are stored only on the
device and leave it only when the user exports a backup.
