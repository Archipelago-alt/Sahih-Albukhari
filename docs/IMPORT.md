# Import workflow

The app's content database is generated — never edited by hand — from the
Shamela text of *Sahih al-Bukhari* (Dar al-Ta'seel edition), book 1284.

## Requirements

- Python ≥ 3.11 with `lxml` (standard library otherwise).
- ~70 MB free disk space for the page cache.

## 1. Fetch the source pages (network, once)

```bash
python3 tool/import/fetch_shamela.py --book 1284 --first 1 --last 4719
```

- Downloads each reader page (one printed page per Shamela page) into
  `data/source/shamela_1284/raw/NNNNN.html.gz`, byte-for-byte as served
  (gzip on disk is lossless), plus the book card (`card.html.gz`).
- Polite: one request at a time with a delay; resumable — re-running skips
  valid cached pages. A full fetch takes a few hours on a slow connection.
- Writes `data/source/shamela_1284/fetch_manifest.json` (SHA-256 of every
  page as served).
- The raw cache is **not committed** (see `.gitignore`); it is re-creatable.

## 2. Build the database (offline, deterministic)

```bash
python3 tool/import/build_database.py --pdf-dir "$HOME/Downloads/Sahih ALbukhari"
```

Outputs:

| File | Purpose |
|---|---|
| `assets/content/bukhari_taseel.db` | SQLite content database bundled in the app |
| `assets/content/content_version.json` | SHA-256 of the database; the app verifies the installed copy against it |
| `data/source/shamela_1284/content_manifest.json` | SHA-256 of each page's text block (`div.nass`), to detect upstream changes |
| `data/generated/bukhari_taseel.json` | Canonical export incl. the raw Shamela paragraphs of every hadith (audit) |
| `data/generated/import_report.json` | Machine-readable validation report |
| `docs/IMPORT_REPORT.md` | Human-readable validation report |
| `tool/import/normalization_vectors.json` | Search-normalization test vectors from real text |

`--pdf-dir` is only used to record the checksums of the verification PDFs.

The exit status is non-zero if the report contains errors.

## 3. Run the checks

```bash
flutter test
```

## Pipeline details

1. **Parse** (`shamela_parser.py`) — each page's `div.nass`: paragraphs,
   footnotes (`p.hamesh`), printed page number, volume, and the table of
   contents expanded in the side navigation.
2. **Merge the TOC** of all pages into one tree.
3. **Exclude** the `مقدمة التحقيق` subtree (the editor's introduction).
4. **Align** every TOC entry with its heading paragraph on the TOC's page
   (number and leading words must agree; differences in wording are
   reported, the body text is used unchanged).
5. **Segment** the text stream: a hadith starts at `• [n]`; text after a
   heading and before the first hadith is the chapter's own text
   (tarjama); text after a hadith belongs to it until the next hadith or
   heading.
6. **Footnote markers**: a numeric `span.c2` is a marker only if the page
   has a footnote with that number and it advances the page's marker
   sequence (or repeats one); otherwise (e.g. an ayah number inside a Quran
   quotation) it stays text and is listed in the report.
7. **Validate** and **write** the database, report and manifests.

## Database schema (content, read-only)

- `books`, `chapters` (with `parent_id`/`depth` for nested chapters and
  `is_implicit` for hadiths that the source places under a book without a
  chapter heading), `hadiths`.
- `footnotes`, `footnote_refs` (owner type, owner id, character offset,
  marker).
- `hadith_search`, `heading_search`: search-only normalized text.
- `meta`: source, card, checksums, importer version.
- `PRAGMA user_version` = content schema version.

Stable identifiers: books `b<number>`, chapters `b<book>-c<path>` (TOC
ordinal path; `c0` = implicit), hadiths `h<number>`. User data refers to
hadiths only by these uids.
