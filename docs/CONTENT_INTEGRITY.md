# Content integrity rules

Sahih al-Bukhari is immutable religious and historical text. These rules are
binding for every change to this repository.

## Sources

| Role | Source |
|---|---|
| Machine-readable text (authoritative for the app) | Al-Maktaba Al-Shamela, book 1284 — <https://shamela.ws/book/1284> ("صحيح البخاري - ط التأصيل") |
| Visual verification | The owner's scanned PDFs of the printed Dar al-Ta'seel edition, 1st ed. 1433 AH / 2012 (`sahih-al-bukhari-arabic-vol-1.pdf` … `vol-10.pdf`, SHA-256 in [IMPORT_REPORT.md](IMPORT_REPORT.md)) |

The PDFs are image-only scans (no text layer); they are never OCR'd into the
app. Neither source file is ever modified.

## What the importer may do

1. Read the cached Shamela pages exactly as served.
2. Exclude the editor's introduction (`مقدمة التحقيق`, Shamela pages 1–152)
   and ornamental separators (`* * *`).
3. Remove the editor's footnote markers (e.g. `(٣)`) from the text, together
   with the single space Shamela places next to each marker. Nothing else in
   the text changes; the integrity tests compare the result with an
   independent extraction of the source. The markers are still located (for
   the report), but neither they nor the footnotes are stored.
4. Move the `• [n] ` prefix of each hadith into the hadith-number field.
5. Join a paragraph that continues across a printed-page boundary with one
   space when the earlier page does not end in terminal punctuation (every
   join is counted in the report).
6. Store a *separate*, search-only normalized copy of the text.

## What nobody may do

- Rewrite, paraphrase, summarise, translate or "correct" any text.
- Add, remove or change letters, diacritics or punctuation.
- Change narrator chains, numbering, book or chapter names, or ordering.
- Merge or drop repeated hadiths; move a hadith to another chapter; invent
  chapter names or numbers.
- Replace text from another website or edition.
- Let normalization touch the displayed, copied, shared or exported text.

## When sources disagree

Differences between Shamela and the printed PDF are recorded in
[VERIFICATION.md](VERIFICATION.md) with the exact location in both sources.
They are never resolved silently; the project owner decides.

## Editor's apparatus

Footnotes (variant readings of the riwayat, explanations of rare words) and
Tuhfat al-Ashraf references are the edition editor's work, not part of
al-Bukhari's text. By the owner's decision of 2026-09-14 the app contains
only the original book names, chapter names, hadith texts, numbering and
references: the **footnotes are not included** (content schema 2), and the
Tuhfat al-Ashraf number is kept as a reference, shown only on request under
the hadith with a label saying it is the editor's addition.

## Checks that must pass before release

- `python3 tool/import/build_database.py` finishes with `errors=0`.
- `flutter test` (including `test/integrity/`) passes.
- New discrepancies found against the PDF are added to VERIFICATION.md.
