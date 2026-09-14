# Full-text vs PDF verification

The app's text comes from Al-Maktaba Al-Shamela, book 1284
(<https://shamela.ws/book/1284>, "صحيح البخاري - ط التأصيل"). The supplied
scanned PDFs of the same printed edition (دار التأصيل، الطبعة الأولى
١٤٣٣هـ/٢٠١٢م) are the visual reference. Shamela's text is used **unchanged**;
every difference found against the PDF is recorded here and nothing is
silently corrected in either direction.

Method: the PDF page is rendered at high resolution, cropped around the
record and compared by eye, word by word and mark by mark, with the Shamela
text (as imported, and the raw Shamela paragraph including footnote
markers). Calligraphic headings are only partly verifiable (see notes).

Page mapping: Shamela `data-page-num` equals the printed page number. For
the PDF files checked so far, PDF page = printed page + 1.

## Volume mapping

Printed page numbers agree between Shamela and the PDFs. Shamela's volume
numbers agree with the volume printed on each title page. Two supplied
**file names** do not match the volume printed inside them:

| Supplied file | Printed volume (title page) | Contents | Shamela volume |
|---|---|---|---|
| `…-vol-1.pdf` | المجلد الأول | front matter; books 1–11 (to باب بدء الأذان) | 1 |
| `…-vol-2.pdf` | (2) | books 12–27 (كتاب الجمعة … كتاب الحج) | 2 |
| `…-vol-3.pdf` | (3) | books 28–53 (باب العمرة … الشروط) | 3 |
| `…-vol-4.pdf` | (4) | books 54–59 (كتاب الوصايا … باب المناقب) | 4 |
| `…-vol-5.pdf` | (5) | books 60–61 (فضائل أصحاب النبي ﷺ … المغازي) | 5 |
| `…-vol-6.pdf` | (6) | books 62–63 (كتاب التفسير, فضائل القرآن) | 6 |
| `…-vol-10.pdf` | **المجلد السابع** | books 64–74 (كتاب النكاح … كتاب اللباس) | 7 |
| `…-vol-8.pdf` | (8) | books 75–84 (كتاب الأدب … كتاب المحاربين) | 8 |
| `…-vol-9.pdf` | (9) | books 85–95 (كتاب الديات … كتاب التوحيد) | 9 |
| `…-vol-7.pdf` | **المجلد العاشر** | indexes only (فهرس الآيات القرآنية … فهرس الرواة) — excluded | — (Shamela: "الفهارس") |

Volumes 2–6, 8 and 9 were identified from their running headers; the title
pages of files vol-1, vol-7 and vol-10 were read directly.

**Correction:** the first inspection report stated that books 75–97 were
missing from the supplied PDFs. That was wrong — it looked only at the file
named `vol-10`, which is printed volume 7. The supplied PDFs cover the whole
collection (95 books in this edition's numbering) plus the index volume.

The app shows Shamela's (= the printed) volume numbers in references.

## Samples

### S1 — Book 1 heading, PDF vol-1 p. 180 (printed 179), Shamela page 153

| | Text |
|---|---|
| Shamela | `١ - كيفَ كَانَ بدءُ الوَحْي إِلَى رَسُوْل اللهِ ﷺ -؟` |
| PDF | calligraphic heading; ends `… رسول الله ﷺ ؟` |

- **D1 (character difference):** Shamela has a hyphen before `؟` (`ﷺ -؟`); the
  PDF shows no hyphen (`ﷺ ؟`).
- Vowel marks of the calligraphic heading could not be verified mark by mark.

### S2 — Book 1 introductory text, same page

| | Text |
|---|---|
| Shamela | `وَقَولُ اللهِ جَلَّ ذِكْرُهُ: ﴿إِنَّا أَوْحَيْنَا إِلَيْكَ كَمَا أَوْحَيْنَا إِلَى نُوحٍ وَالنَّبِيِّينَ مِنْ بَعْدِهِ﴾` |
| PDF | `وَقَولُِ⁽٢⁾ اللهِ جَلَّ ذِكْرُهُ⁽٣⁾ :` then the verse in Uthmani script |

- **D2 (character difference):** the PDF prints both a ḍamma and a kasra on
  the lām of `وَقَولُِ` (the editor's footnote ٢ reads «كذا بالضبطين معًا»);
  Shamela has only the ḍamma here. (On Shamela page 167 the same word keeps
  both marks: `وَقَوْلُِ`.)
- **D3 (systematic):** Quran quotations are printed in Uthmani (Mushaf)
  orthography (`إِنَّآ أَوْحَيْنَآ … وَٱلنَّبِيِّـۧنَ مِنۢ بَعْدِهِۦ`); Shamela gives them
  in standard orthography (`إِنَّا أَوْحَيْنَا … وَالنَّبِيِّينَ مِنْ بَعْدِهِ`).

### S3 — Hadith [١], PDF vol-1 pp. 180–181, Shamela pages 153–154

Shamela (imported, markers removed):

> حدثنا الْحُمَيْدِيُّ عَبْدُ اللَّهِ بْنُ الزُّبَيْرِ، قَالَ: حَدَّثَنَا سُفْيَانُ، قَالَ: حَدَّثَنَا يَحْيَى بْنُ سَعِيدٍ الْأَنْصَارِيُّ، قَالَ: أَخْبَرَنِي مُحَمَّدُ بْنُ إِبْرَاهِيمَ التَّيْمِيُّ، أَنَّهُ سَمِعَ عَلْقَمَةَ بْنَ وَقَّاصٍ اللَّيْثِيَّ يَقُولُ: سَمِعْتُ عُمَرَ بْنَ الْخَطَّابِ ﵁ عَلَى الْمِنْبَرِ قَالَ: سَمِعْتُ رَسُولَ اللَّهِ ﷺ يَقُولُ: "إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى، فَمَنْ كَانَتْ هِجْرَتُهُ إِلَى دُنْيَا يُصِيبُهَا، أَوْ إِلَى امْرَأَةٍ يَنْكِحُهَا فَهِجْرَتُهُ إِلَى مَا هَاجَرَ إِلَيْهِ".

- Letters, word order, isnad and footnote-marker positions (٥–٩, then ١–٢ on
  the next page) match the PDF.
- The hadith continues across the page break (`… يُصِيبُهَا، أَوْ` / `إِلَى امْرَأَةٍ …`);
  the importer joins the two parts with one space, as the print reads.
- **D4 (systematic):** the PDF writes a final alif maqṣūra with a small
  superscript alif where Shamela has a bare `ى`: PDF `يَحْيَىٰ`, `إِلَىٰ`;
  Shamela `يَحْيَى`, `إِلَى`.
- **D5 (systematic):** quotation marks: PDF `«…»`, Shamela `"…"`.
- **D6 (systematic, spacing):** the PDF sets a space before `،` and `:`
  (`الزُّبَيْرِ ، قَالَ :`); Shamela does not.
- **D7 (formatting only):** the PDF prints the Prophet's words in bold; in
  this hadith Shamela does not mark them (in most hadiths it does, `span.c1`).

### S4 — Hadiths [١٥]–[١٨], chapters ٩–١١, PDF vol-1 pp. 200–201 (printed 199–200), Shamela pages 173–174

Compared word by word at high resolution. Letters, vowel marks, isnads,
chapter wording and footnote-marker positions match, except:

- **D8 (character difference):** chapter ١٠ — PDF `بَابٌُ` (tanwīn *and* ḍamma;
  footnote ١: «كذا بالضبطين»); Shamela `بَابٌ`. Same pattern as D2: where the
  print gives two vowelings, Shamela keeps one.
- **D9 (character difference):** hadith [١٧] — PDF `عَبْدِ اللَّهِ` / `ابْنِ جَبْرٍ`
  (the second «ابن» starts a printed line and is written with alif);
  Shamela `بْنِ جَبْرٍ`.
- **D10 (character difference):** hadith [١٨] — PDF `شُعَيْبٌ` (sukūn on the
  yā'); Shamela `شُعَيبٌ`.
- **D11 (character difference):** hadith [١٨] — PDF `الصَّامِتِ ﵁ – وَكَانَ شَهِدَ بَدْرًا … لَيْلَةَ الْعَقَبَةِ – أَنَّ`
  (parenthetical opened and closed with a dash); Shamela has only the closing
  dash: `﵁ وَكَانَ … الْعَقَبَةِ - أَنَّ`.
- D4 again: PDF `حَتَّىٰ`, `الْمُثَنَّىٰ`, `عَلَىٰ`; Shamela `حَتَّى`, `الْمُثَنَّى`, `عَلَى`.
- D5, D6 again (quotation marks, space before `،`/`:`); headings are set
  `٩- بَابُ` in print and `٩ - بَابُ` in Shamela (spacing only).
- The printed ligature for the name of Allah does not show whether a
  separate shadda/dagger alif is encoded; Shamela writes `اللَّهُ` in hadith
  text and `اللهِ` in some headings. Not decidable from the image.

### S5 — Chapter ٢ of كتاب الجمعة, hadiths [٨٨٧]–[٨٨٩], PDF vol-2 p. 7 (printed 6), Shamela page 698

- Chapter heading (two printed lines) and the three hadiths match letter
  for letter and mark for mark, except the recurring patterns below.
- **D9 again (systematic):** hadith [٨٨٧] — PDF `عَنْ عَبْدِ اللَّهِ` / `ابْنِ عُمَرَ`
  (line-initial «ابن» with alif); Shamela `بْنِ عُمَرَ`. With S4 this shows a
  typesetting convention of the print (alif added to «ابن» that begins a
  printed line) which Shamela does not reproduce.
- D4, D5, D6 again.

### S6 — باب العمرة, hadiths [١٧٨٤]–[١٧٨٦], PDF vol-3 p. 7 (printed 6), Shamela page 1186

- `أَرْبَعً` (without final alif, with the editor's note ٤) is printed exactly
  so; Shamela matches. Chapter ٣ is `بَابٌ` in both.
- **D1 again (systematic):** chapter heading ends `النَّبِيُّ ﷺ؟` in print;
  Shamela `النَّبِيُّ ﷺ -؟` (extra hyphen, as in the heading of book 1).
- **D12 (character difference):** `قَبْلَ أَنْ يَحُجَّ` — PDF has a fatha on the
  qāf; Shamela `قبْلَ`.
- **D13 (character difference):** hadith [١٧٨٥] — PDF `عَنْ مَنْصُورٍ`; Shamela
  `مَنْصورٍ` (no ḍamma on the ṣād).
- Not verified: `فَإذَا` (Shamela) — the mark under the alif could not be read
  reliably from the scan crop.

### S7 — كتاب الوصايا, hadiths [٢٧٥٦]–[٢٧٥٨], PDF vol-4 p. 7 (printed 6), Shamela page 1752

Isnads, matn words and punctuation match; the differences are missing
vowel marks in Shamela:

- **D14:** hadith [٢٧٥٦] — PDF `خَتَنِ رَسُولِ اللَّهِ`; Shamela `ختَنِ` (no fatha on
  the khā'; read at strip resolution).
- **D15:** hadith [٢٧٥٧] — PDF `أَبِي أَوْفَىٰ`; Shamela `أَوفَى` (no sukūn on the
  wāw; plus D4).
- **D16:** hadith [٢٧٥٧] — PDF `بِالْوَصِيَّةِ`; Shamela `بِالوَصِيَّةِ` (no sukūn on
  the lām).
- **D17:** hadith [٢٧٥٨] — PDF `مُسْنِدَتَهُ`; Shamela `مُسنِدَتَه` (no sukūn on
  the sīn, no ḍamma on the final hā').
- D4, D5, D6 again.

### S8 — كتاب النكاح, end of [٥٠٥٣] and hadith [٥٠٥٤], PDF file vol-10 p. 7 (printed vol. 7 p. 6), Shamela page 3339

- Isnad, matn, punctuation, markers ١–٣ and both Tuhfa references match.
- **D18:** PDF `أَنْتُمُ الَّذِينَ`; Shamela `الَّذينَ` (no kasra on the dhāl).
- **D19:** PDF `كَذَا وَكَذَا`; Shamela `كَذا وَكَذا` (no fatha on the dhāl).
- **D20:** PDF `لَأَخْشَاكُمْ`; Shamela `لَأَخْشَاكمْ` (no ḍamma on the kāf).
- Probable: PDF `لِلَّهِ` (ligature), Shamela `لِلهِ` (no shadda) — ligature makes
  the printed marks hard to confirm.
- **D21 (editor's apparatus, not hadith text):** the printed page numbers its
  footnotes (١) (٢) (٣) (٥) (٦) — there is no (٤) in print. Shamela numbers
  them (١)…(٥), so in the app the gloss on «تقسطوا» is marker (٤) and the
  verse reference [النساء: ٣] is marker (٥), where the print has (٥) and (٦).
  Footnote texts match.
- D3 (Uthmani Quran), D4, D5, D6 again.

### S9 — Last hadith [٧٥٥٩], PDF vol-9 p. 432 (printed vol. 9 p. 431), Shamela page 4719

- Isnad, matn and vowel marks match letter for letter; footnotes (١)–(٣)
  and the Tuhfa reference `[التحفة: خ م ت سي ق ١٤٨٩٩]` match.
- The closing ornament `* * *` is printed too; the importer skips it (it is
  not text).
- Only D5/D6 (quotation marks, spacing before punctuation) differ.

### S10 — End of [٣٦٤١], hadith [٣٦٤٢], chapter ١ of مناقب المهاجرين, PDF vol-5 p. 7 (printed 6), Shamela page 2292

- Text, both dashes of the parenthetical `– قَالَ عِمْرَانُ … ثَلَاثًا –`, the
  repeated marker (٤), the dual vowelings `مَنَاقِبُِ` / `وَفَضْلُِهُِمْ` and the
  footnotes match. (So Shamela does keep dual vowelings in places; D2/D8 are
  local omissions, not a systematic rule.)
- **D22:** PDF `عَنْ إِبْرَاهِيمَ`; Shamela `إِبرَاهِيمَ` (no sukūn on the bā').
- D5, D6 again.

### S11 — كتاب الأدب, chapters ٤–٥, hadiths [٥٩٧٧]–[٥٩٧٨], PDF vol-8 p. 8 (printed 7), Shamela page 3826

- Both chapter headings, isnads, matn, markers (١)–(٨), footnotes and Tuhfa
  references match.
- D9 again: PDF `عَنْ حُمَيْدِ` / `ابْنِ عَبْدِ الرَّحْمَنِ` (line-initial «ابن»);
  Shamela `بْنِ عَبْدِ الرَّحْمَنِ`.
- Not verified: the first vowel of `يتَمَاشَوْنَ` (Shamela has no mark on the
  yā'); the bold print does not show it clearly.
- D5, D6 again.

### S12 — Start of كتاب التفسير (سورة الفاتحة), hadiths [٤٤٥٣]–[٤٤٥٤], PDF vol-6 p. 7 (printed 6), Shamela page 2770

- Isnads, matn, markers (١)–(٥), the chapter heading `١ - بَابُ ﴿غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ﴾`
  and footnotes match (Quran quotations: D3).
- **D23:** PDF `فَلَمْ أُجِبْهُ`; Shamela `فلَمْ` (no fatha on the fā').
- **D24:** PDF `قُلْتُ لَهُ: أَلَمْ تَقُلْ`; Shamela `أَلمْ` (no fatha on the lām).
- **D25:** hadith [٤٤٥٤] — PDF `ﷺ قَالَ: إِذَا`; Shamela `قالَ` (no fatha on the qāf).
- D5, D6 again.

## Source irregularities found by the importer

These are listed in full in [IMPORT_REPORT.md](IMPORT_REPORT.md). They are kept
exactly as Shamela has them.

- **Footnote numbers typed as text** inside parenthesised text, instead of
  as footnote markers (4 places). They are shown as text, exactly as in the
  source:
  - Shamela page 260 (printed vol. 1 p. 287), hadith [١٢٩]: `(وَمَا أُوتُوا (٣)`
    — footnote ٣ of that page therefore has no marker.
  - page 2811 (printed vol. 6 p. 47): `(نُنْشِرُهَا (١٣)`
  - page 2944 (printed vol. 6 p. 180): `(مُجْرِيهَا (١٢)` — footnote ١٢ of that
    page therefore has no marker.
  - page 4631 (printed vol. 9 p. 343): `((٧)`
- **Footnotes never referenced by a marker:** page 260 (٣) and page 2944
  (١٢) — the two cases above. Recorded as a property of the source; the
  app no longer includes the editor's footnotes.
- **Bracketed text marked up as a hadith number** inside a paragraph: page
  1118 (printed vol. 3 p. 434), `[الطور: ١، ٢]`. It is a Quran reference, so
  it is kept as text and does not start a new record.
- **Numbers in parentheses that are not footnote markers:** 178 inside Quran
  quotations (ayah numbers) and 35 elsewhere; all kept as text. The 35 are
  listed in the import report for review.
- **Chapter headings missing from Shamela's table of contents:** 341
  headings exist only in the body text (mostly in كتاب التفسير). They were
  accepted because their numbering continues the sequence; each is listed in
  the import report.
- **Records under two numbers:** 118 texts are printed under a pair such as
  [٤١٢ - ٤١٣]. They are kept as one record, searchable and reachable by
  either number.

Checks that found nothing: missing hadith numbers (1–7559 all present),
numbering order breaks, footnote markers without a footnote, bullet
paragraphs without a number, importer errors and warnings.

## Known limitations

- Only representative records (S1–S12) were compared with the PDFs; the
  rest of the text is Shamela's, checked structurally by the importer and
  by the integrity tests, not by eye.
- The comparison is visual; the PDFs are image-only and were not OCR'd, so
  a difference outside the sampled records would not be detected.
- Calligraphic book headings in the print can only be partly compared.
- D3–D6 show that Shamela's digital text differs systematically from the
  print in some marks and typography; the app shows Shamela's form
  everywhere.
- Printed page references are Shamela's page numbers, which match the print;
  they are not the PDF file page numbers (PDF page = printed page + 1).

## Decisions needed

The app shows Shamela's text unchanged in every case below. Each one needs
the project owner's decision; the importer can apply a reviewed, documented
exception list if the owner decides to follow the print anywhere.

- D1, D2: character-level differences in specific places.
- D3–D6: systematic orthographic/typographic differences between Shamela's
  digital text and the print.
- D7–D25: diacritic differences in individual words (listed per sample
  above).
- The four footnote numbers typed as text (pages 260, 2811, 2944, 4631):
  keep as text (current — they are typed as part of Shamela's text), or
  remove them like the other footnote markers.
- Licensing: resolved for the private, non-commercial test app (owner's
  decision, 2026-09-14); redistribution needs review before any public
  release — see [DATA_LICENSE.md](DATA_LICENSE.md).
