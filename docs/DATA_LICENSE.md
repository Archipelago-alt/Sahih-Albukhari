# Data licensing status

## Owner's decision (2026-09-14)

The project owner has authorised the use of the Sahih al-Bukhari text from
Al-Maktaba Al-Shamela (<https://shamela.ws/book/1284>) as the app's data
source for a **private, non-commercial test application**. Licensing does
not block development.

Conditions set by the owner:

- Attribution to Al-Maktaba Al-Shamela and to the identified printed edition
  (*Sahih al-Bukhari*, revised and corrected against the Sultaniyya edition,
  Dar al-Ta'seel, Cairo, 1st edition, 1433 AH / 2012 CE) is kept in the
  README and on the app's About screen.
- The app contains only the original book names, chapter names, hadith
  texts, their numbering and references (printed volume/page and the
  Tuhfat al-Ashraf numbers). The editor's introduction, the editor's
  footnotes and other supplementary material are excluded. The footnotes
  were removed from the database in content schema version 2.
- No APK, app-store release or packaged book database is published
  publicly for now.

## Application code

Licensed under the MIT License (see [LICENSE](../LICENSE)). This covers the
Dart/Flutter code, the import tools, tests and documentation — not the book
text.

## Redistribution considerations (for later review)

None of these blocks the private test build. They need a decision before
any public release.

- The classical text of Imam al-Bukhari (d. 256 AH) is in the public
  domain, but the edition's presentation — vocalisation, punctuation,
  numbering and the Tuhfat al-Ashraf references — is the editor's work. The
  printed Dar al-Ta'seel edition carries an "all rights reserved" notice
  (vol. 1, PDF page 5).
- Al-Maktaba Al-Shamela publishes the text for reading and research. Its
  robots.txt allows crawling and declares
  `Content-Signal: search=yes, ai-train=no, use=reference`. This project
  does not use the text to train any model. Shamela's terms do not, by
  themselves, grant a licence to redistribute the publisher's edition.
- A public release (store listing, public APK, or a public copy of the
  database) would need written permission from Dar al-Ta'seel
  (<www.taaseel.com>) and, if required, from Al-Maktaba Al-Shamela — or
  another licensed source.
- The Tuhfat al-Ashraf numbers are kept as references by the owner's
  decision; they are editorial work and belong in the same review.
- **The GitHub repository is public.** It does not contain the database,
  the raw Shamela pages, the generated export or any APK (all gitignored),
  but it does contain excerpts of the book:
  - the full text of 17 hadiths in `test/integrity/fixtures.json`;
  - book and chapter headings, and per-chapter lists, in
    `docs/IMPORT_REPORT.md`;
  - short samples of book titles, chapter titles and hadith openings in
    `tool/import/normalization_vectors.json`;
  - quoted passages in `docs/VERIFICATION.md`.

  Making the repository private, or dropping these excerpts from future
  commits, is the owner's decision. Removing them from earlier commits
  would require rewriting Git history, which this project does not do
  without explicit instruction.

Until that review:

1. The raw Shamela cache (`data/source/*/raw/`), the generated database
   (`assets/content/bukhari_taseel.db`) and the canonical export
   (`data/generated/`) stay **excluded from Git**.
2. APKs are built locally and shared privately only.
3. The About screen and the README keep the attribution above.

## Fonts

| Font | Licence | File |
|---|---|---|
| Amiri 1.003 | SIL Open Font License 1.1 | `assets/fonts/amiri/OFL.txt` |
| Noto Naskh Arabic 2.021 | SIL Open Font License 1.1 | `assets/fonts/noto_naskh_arabic/OFL.txt` |
| Noto Sans Arabic 2.013 | SIL Open Font License 1.1 | `assets/fonts/noto_sans_arabic/OFL.txt` |

The fonts are redistributed unmodified; their licences are shown in the
app's licence page.

## App icon

Original artwork generated from geometry in `tool/icon/generate_icon.py`
(no third-party assets); covered by the application-code licence.
