import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sahih_albukhari/core/arabic/arabic_normalizer.dart';
import 'package:sahih_albukhari/data/content/search_repository.dart';
import 'package:sahih_albukhari/features/search/search_highlighter.dart';

/// Hadith [١٦] exactly as extracted from the Shamela source by the
/// independent fixture extractor (tool/import/make_integrity_fixtures.py).
String loadHadith16() {
  final json = jsonDecode(File('test/integrity/fixtures.json').readAsStringSync()) as Map<String, dynamic>;
  final hadiths = (json['hadiths'] as List).cast<Map<String, dynamic>>();
  return hadiths.firstWhere((h) => h['number'] == 16)['text'] as String;
}

String cut(String s, MatchRange r) => s.substring(r.start, r.end);
String norm(String s) => ArabicNormalizer.normalize(s);

void main() {
  late String hadith16;
  setUpAll(() => hadith16 = loadHadith16());

  test('normalized word search highlights the original, vowelled word', () {
    final r = SearchHighlighter.find(hadith16, const SearchRequest(query: 'الايمان'));
    expect(r, hasLength(1));
    final word = cut(hadith16, r.single);
    expect(norm(word), 'الايمان');
    expect(word.length, greaterThan('الايمان'.length), reason: 'diacritics of the original are included');
  });

  test('all-words mode highlights every word', () {
    final r = SearchHighlighter.find(hadith16, const SearchRequest(query: 'حلاوة النار'));
    expect(r.map((m) => norm(cut(hadith16, m))), ['حلاوة', 'النار']);
  });

  test('phrase mode requires the words together and in order', () {
    expect(
      SearchHighlighter.find(hadith16, const SearchRequest(query: 'حلاوة الايمان', mode: SearchMode.phrase)),
      hasLength(1),
    );
    expect(
      SearchHighlighter.find(hadith16, const SearchRequest(query: 'الايمان حلاوة', mode: SearchMode.phrase)),
      isEmpty,
    );
  });

  test('exact mode compares characters including diacritics', () {
    final r = SearchHighlighter.find(hadith16, const SearchRequest(query: 'حلاوة'));
    final vowelled = cut(hadith16, r.single);
    expect(SearchHighlighter.find(hadith16, SearchRequest(query: vowelled, mode: SearchMode.exact)), hasLength(1));
    expect(SearchHighlighter.find(hadith16, const SearchRequest(query: 'حلاوة', mode: SearchMode.exact)), isEmpty);
  });

  test('whole-word option rejects matches inside longer words', () {
    expect(SearchHighlighter.find(hadith16, const SearchRequest(query: 'كره')), hasLength(2));
    expect(SearchHighlighter.find(hadith16, const SearchRequest(query: 'كره', wholeWords: true)), isEmpty);
  });

  test('broad mode folds ta marbuta', () {
    expect(SearchHighlighter.find(hadith16, const SearchRequest(query: 'حلاوه')), isEmpty);
    expect(SearchHighlighter.find(hadith16, const SearchRequest(query: 'حلاوه', broad: true)), hasLength(1));
  });

  test('snippet is an unmodified substring containing the match', () {
    final r = SearchHighlighter.find(hadith16, const SearchRequest(query: 'النار'));
    final s = SearchHighlighter.snippet(hadith16, r, context: 30);
    expect(hadith16.contains(s.text), isTrue);
    expect(s.clippedStart, isTrue);
    expect(norm(s.text.substring(s.matches.first.start, s.matches.first.end)), 'النار');
  });

  test('hadith number queries are recognised in both digit systems', () {
    expect(const SearchRequest(query: '١٦').hadithNumber, 16);
    expect(const SearchRequest(query: ' 7559 ').hadithNumber, 7559);
    expect(const SearchRequest(query: 'باب 3').hadithNumber, isNull);
  });
}
