# Data licensing status

**The application code and the book data have different licensing status.
The project owner must resolve the book-data question before any public
distribution of the app or of the generated database.**

## Application code

Licensed under the MIT License (see [LICENSE](../LICENSE)). This covers the
Dart/Flutter code, the import tools, tests and documentation — not the book
text.

## Book text and editorial apparatus — decision required

- The classical text of Imam al-Bukhari (d. 256 AH) is in the public domain.
- The *edition* is not: the printed Dar al-Ta'seel edition (Cairo, 1st ed.
  1433 AH / 2012) carries an "all rights reserved" notice (vol. 1, PDF page
  5) that prohibits reproduction, electronic storage/retrieval, quotation or
  modification without the publisher's written permission. The edition's
  vocalisation, punctuation, numbering, variant-reading footnotes, word
  glosses and Tuhfat al-Ashraf references are the editor's work.
- The machine-readable text comes from Al-Maktaba Al-Shamela
  (<https://shamela.ws/book/1284>), which publishes it for reading and
  research. Its robots.txt allows crawling and declares
  `Content-Signal: search=yes, ai-train=no, use=reference`. This project
  does not use the text to train any model. Shamela's terms do not, by
  themselves, grant a licence to redistribute the publisher's edition.
- Owning a physical or digital copy of the book does not grant a right to
  redistribute the edition.

Therefore:

1. The raw Shamela cache (`data/source/*/raw/`), the generated database
   (`assets/content/bukhari_taseel.db`) and the canonical export
   (`data/generated/`) are **excluded from Git**.
2. Before publishing the app (store listing, public APK, public
   repository containing the database), the owner should obtain written
   permission from Dar al-Ta'seel (<www.taaseel.com>) — and, if required,
   from Al-Maktaba Al-Shamela — or decide on another licensed source.
3. The app's About screen attributes the text to Al-Maktaba Al-Shamela and
   to the printed edition.

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
