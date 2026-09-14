# Contributing

Thank you for helping. Please read [docs/CONTENT_INTEGRITY.md](docs/CONTENT_INTEGRITY.md)
first: **the text of Sahih al-Bukhari must never be edited, corrected or
paraphrased**, in code, data or tests.

## Setup

See the README for the Flutter/Dart versions. Then:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # drift code
flutter gen-l10n
```

The content database is generated, not committed; follow
[docs/IMPORT.md](docs/IMPORT.md) to build it.

## Before opening a pull request

```bash
dart format --line-length 120 lib test integration_test
flutter analyze
flutter test
```

- Keep changes focused; one topic per commit.
- Every user-visible string goes in `lib/l10n/app_ar.arb` **and**
  `lib/l10n/app_en.arb`; no hard-coded UI text.
- Arabic text from the book is laid out right-to-left regardless of the UI
  language (`ArabicText`, `SourceText`).
- Tests that need hadith text must use real text from the imported source
  (see `test/integrity/`), never invented religious text.
- Never commit signing keys, keystores, passwords or tokens.
- Do not add analytics, advertising, accounts, network access, AI-generated
  explanations/rulings or machine translations.

## Changing the importer

Re-run `tool/import/build_database.py`, review the diff of
`docs/IMPORT_REPORT.md`, and run the tests. Any change in record counts,
numbering or text must be explained in the pull request.

## Reporting a text problem

Open an issue with the hadith number, the Shamela page
(`https://shamela.ws/book/1284/<page>`) and the printed volume/page. Do not
submit a "corrected" text; differences are recorded in
[docs/VERIFICATION.md](docs/VERIFICATION.md) and decided by the maintainer.
