import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahih_albukhari/data/content/content_models.dart';
import 'package:sahih_albukhari/features/reader/hadith_share_text.dart';
import 'package:sahih_albukhari/features/reader/source_text_spans.dart';
import 'package:sahih_albukhari/features/search/search_highlighter.dart';

// A chapter heading used as sample text for span building (the ranges below
// are offsets into this string; it is not compared with the database).
const heading = '٩ - بَابُ حَلَاوَةِ الْإِيمَانِ';

const styles = SourceTextStyles(
  base: TextStyle(fontSize: 20),
  emphasis: TextStyle(fontWeight: FontWeight.w700),
  highlight: Color(0xFFFFFF00),
);

String plain(List<InlineSpan> spans) => spans.whereType<TextSpan>().map((s) => s.text).join();

const hadith = Hadith(
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

void main() {
  test('spans reproduce the original text exactly', () {
    final spans = buildSourceTextSpans(
      text: heading,
      styles: styles,
      styleSpans: const [StyleSpan('c1', 4, 9)],
      highlights: const [MatchRange(10, 19)],
    );
    expect(plain(spans), heading);
    expect(plain(buildSourceTextSpans(text: heading, styles: styles)), heading);
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

  test('copied text starts with the untouched hadith text', () {
    expect(HadithShareText.plain(hadith: hadith, reference: 'REF'), '$heading\n\nREF');
    expect(
      HadithShareText.withTuhfa(hadith: hadith, reference: 'REF', tuhfaLabel: 'تحفة الأشراف'),
      '$heading\n\nتحفة الأشراف: [التحفة: خ م ت ٩٤٦]\n\nREF',
    );
  });

  test('copy with Tuhfa falls back to the plain text when there is none', () {
    const noTuhfa = Hadith(
      id: 2,
      uid: 'h2',
      sortOrder: 2,
      bookId: 1,
      chapterId: 1,
      number: 2,
      numberText: '٢',
      text: heading,
      spans: [],
      volume: 1,
      printedPageStart: '199',
      printedPageEnd: '199',
      tuhfa: null,
    );
    expect(
      HadithShareText.withTuhfa(hadith: noTuhfa, reference: 'REF', tuhfaLabel: 'x'),
      HadithShareText.plain(hadith: noTuhfa, reference: 'REF'),
    );
  });
}
