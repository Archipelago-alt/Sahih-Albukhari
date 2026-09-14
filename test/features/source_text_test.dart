import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahih_albukhari/data/content/content_models.dart';
import 'package:sahih_albukhari/features/reader/hadith_share_text.dart';
import 'package:sahih_albukhari/features/reader/source_text_spans.dart';
import 'package:sahih_albukhari/features/search/search_highlighter.dart';

// Chapter heading of Shamela page 173: "٩ - بَابُ (٤) حَلَاوَةِ الْإِيمَانِ";
// display text without the editor marker, which sits at offset 9.
const heading = '٩ - بَابُ حَلَاوَةِ الْإِيمَانِ';
const marker = FootnoteRef(offset: 9, marker: '(٤)', footnoteId: 1, footnoteText: 'سقط عند الأصيلي.');

const styles = SourceTextStyles(
  base: TextStyle(fontSize: 20),
  emphasis: TextStyle(fontWeight: FontWeight.w700),
  marker: TextStyle(fontSize: 12),
  highlight: Color(0xFFFFFF00),
);

String plain(List<InlineSpan> spans, {bool skipMarkers = true}) =>
    spans.whereType<TextSpan>().where((s) => !skipMarkers || s.style != styles.marker).map((s) => s.text).join();

void main() {
  test('spans reproduce the original text exactly', () {
    final spans = buildSourceTextSpans(
      text: heading,
      styles: styles,
      markers: const [marker],
      styleSpans: const [StyleSpan('c1', 4, 9)],
      highlights: const [MatchRange(10, 19)],
    );
    expect(plain(spans), heading);
  });

  test('markers are inserted at their recorded offset, only when shown', () {
    final shown = buildSourceTextSpans(text: heading, styles: styles, markers: const [marker]);
    expect(plain(shown, skipMarkers: false), '٩ - بَابُ(٤) حَلَاوَةِ الْإِيمَانِ');
    final hidden = buildSourceTextSpans(text: heading, styles: styles, markers: const [marker], showMarkers: false);
    expect(plain(hidden, skipMarkers: false), heading);
  });

  test('emphasis and highlight styles cover exactly their ranges', () {
    final spans = buildSourceTextSpans(
      text: heading,
      styles: styles,
      styleSpans: const [StyleSpan('c1', 4, 9)],
      highlights: const [MatchRange(10, 19)],
    ).cast<TextSpan>();
    final bold = spans.where((s) => s.style?.fontWeight == FontWeight.w700).map((s) => s.text).join();
    final lit = spans.where((s) => s.style?.backgroundColor != null).map((s) => s.text).join();
    expect(bold, 'بَابُ');
    expect(lit, 'حَلَاوَةِ');
  });

  test('textWithMarkers restores the source form', () {
    expect(textWithMarkers(heading, const [marker]), '٩ - بَابُ(٤) حَلَاوَةِ الْإِيمَانِ');
  });

  test('copied text starts with the untouched hadith text', () {
    const h = Hadith(
      id: 1,
      uid: 'h1',
      sortOrder: 1,
      bookId: 1,
      chapterId: 1,
      number: 1,
      numberText: '١',
      text: heading,
      spans: [],
      volume: 1,
      printedPageStart: '199',
      printedPageEnd: '199',
      tuhfa: '[التحفة: خ م ت ٩٤٦]',
    );
    final plainText = HadithShareText.plain(hadith: h, reference: 'REF');
    expect(plainText, '$heading\n\nREF');
    final withNotes = HadithShareText.withEditorNotes(
      hadith: h,
      footnotes: const [marker],
      reference: 'REF',
      notesTitle: 'حواشي المحقق',
      tuhfaLabel: 'تحفة الأشراف',
    );
    expect(withNotes, startsWith('٩ - بَابُ(٤) حَلَاوَةِ الْإِيمَانِ\n\n— حواشي المحقق —\n(٤) سقط عند الأصيلي.'));
    expect(withNotes, contains('تحفة الأشراف: [التحفة: خ م ت ٩٤٦]'));
    expect(withNotes, endsWith('\n\nREF'));
  });
}
