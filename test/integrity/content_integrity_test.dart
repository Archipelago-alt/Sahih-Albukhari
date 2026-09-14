// Integrity of the generated content database (assets/content/bukhari_taseel.db)
// against the source. Fixtures are produced from the raw Shamela pages by an
// independent extractor (tool/import/make_integrity_fixtures.py).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sahih_albukhari/core/arabic/arabic_normalizer.dart';
import 'package:sahih_albukhari/data/content/content_database.dart';
import 'package:sahih_albukhari/data/content/content_repository.dart';
import 'package:sahih_albukhari/data/content/search_repository.dart';

import '../helpers/harness.dart';

void main() {
  if (!contentAvailable) {
    test('content database', () {}, skip: 'content database not built (see docs/IMPORT.md)');
    return;
  }
  late ContentDatabase db;
  late ContentRepository repo;
  late SearchRepository search;

  Future<int> scalar(String sql) async => (await db.customSelect(sql).getSingle()).data.values.first as int;

  setUpAll(() {
    db = openContent();
    repo = ContentRepository(db);
    search = SearchRepository(db);
  });
  tearDownAll(() => db.close());

  group('structure', () {
    test('schema version is supported', () async {
      expect(await repo.schemaVersion(), ContentDatabase.supportedSchemaVersion);
    });

    test('books are in original order with sequential numbers', () async {
      final books = await repo.books();
      expect(books, isNotEmpty);
      for (var i = 0; i < books.length; i++) {
        expect(books[i].sortOrder, i + 1);
        expect(books[i].number, i + 1, reason: books[i].heading);
        expect(books[i].title.trim(), isNotEmpty);
      }
    });

    test('every hadith belongs to a chapter of its own book', () async {
      expect(
        await scalar(
          'SELECT COUNT(*) FROM hadiths h JOIN chapters c ON c.id = h.chapter_id WHERE c.book_id != h.book_id',
        ),
        0,
      );
      expect(await scalar('SELECT COUNT(*) FROM hadiths WHERE chapter_id NOT IN (SELECT id FROM chapters)'), 0);
    });

    test('hadith order never goes back to an earlier chapter or book', () async {
      expect(
        await scalar('''
          SELECT COUNT(*) FROM (
            SELECT c.sort_order AS cs, b.sort_order AS bs,
                   LAG(c.sort_order) OVER (ORDER BY h.sort_order) AS pc,
                   LAG(b.sort_order) OVER (ORDER BY h.sort_order) AS pb
            FROM hadiths h JOIN chapters c ON c.id = h.chapter_id JOIN books b ON b.id = h.book_id)
          WHERE cs < pc OR bs < pb'''),
        0,
      );
    });

    test('hadith numbers are unique and increasing', () async {
      expect(await scalar('SELECT COUNT(*) - COUNT(DISTINCT number) FROM hadiths'), 0);
      expect(
        await scalar('''
          SELECT COUNT(*) FROM (SELECT number, LAG(number) OVER (ORDER BY sort_order) AS p FROM hadiths)
          WHERE number <= p'''),
        0,
      );
    });

    test('stored counts equal the actual rows', () async {
      expect(
        await scalar(
          'SELECT COUNT(*) FROM chapters c WHERE hadith_count != '
          '(SELECT COUNT(*) FROM hadiths h WHERE h.chapter_id = c.id)',
        ),
        0,
      );
      expect(
        await scalar(
          'SELECT COUNT(*) FROM books b WHERE hadith_count != '
          '(SELECT COUNT(*) FROM hadiths h WHERE h.book_id = b.id)',
        ),
        0,
      );
    });

    test('no empty hadith text, no empty headed chapter names', () async {
      expect(await scalar("SELECT COUNT(*) FROM hadiths WHERE trim(text) = ''"), 0);
      expect(await scalar("SELECT COUNT(*) FROM chapters WHERE is_implicit = 0 AND trim(coalesce(title,'')) = ''"), 0);
    });

    test("the editor's footnotes are not in the database; references are", () async {
      final tables = [
        for (final r in await db.customSelect("SELECT name FROM sqlite_master WHERE type = 'table'").get())
          r.read<String>('name'),
      ];
      expect(tables, isNot(contains('footnotes')));
      expect(tables, isNot(contains('footnote_refs')));
      expect(await scalar('SELECT COUNT(*) FROM hadiths WHERE tuhfa IS NOT NULL'), greaterThan(0));
    });
  });

  group('text is exactly the source', () {
    final fixtures =
        ((jsonDecode(File('test/integrity/fixtures.json').readAsStringSync()) as Map<String, dynamic>)['hadiths']
                as List)
            .cast<Map<String, dynamic>>();

    for (final f in fixtures) {
      test('hadith ${f['number_text']} matches the independently extracted source text', () async {
        final found = await repo.hadithsByNumber(f['number'] as int);
        expect(found, hasLength(1));
        expect(found.single.numberText, f['number_text']);
        expect(found.single.text, f['text']);
      });
    }

    test('hadith 16 sits under "٩ - بَابُ حَلَاوَةِ الْإِيمَانِ" in كتاب الإيمان', () async {
      final h = (await repo.hadithsByNumber(16)).single;
      final c = await repo.chapter(h.chapterId);
      final b = await repo.book(h.bookId);
      expect(c.heading, '٩ - بَابُ حَلَاوَةِ الْإِيمَانِ');
      expect(b.heading, '٢ - كِتَابُ الإيمَانِ');
    });

    test('displayed text keeps its diacritics; normalization lives only in the search table', () async {
      final h = (await repo.hadithsByNumber(1)).single;
      final harakat = RegExp('[\u064B-\u0652]');
      expect(harakat.hasMatch(h.text), isTrue);
      final norm = (await db.customSelect('SELECT norm FROM hadith_search WHERE id = ${h.id}').getSingle())
          .read<String>('norm');
      expect(norm, ArabicNormalizer.normalize(h.text));
      expect(harakat.hasMatch(norm), isFalse);
    });
  });

  group('search', () {
    test('word, phrase and exact searches find hadith 16', () async {
      final hadith16 = (await repo.hadithsByNumber(16)).single;
      final h16 = hadith16.id;
      // The exact-mode query is taken from the stored source text itself.
      final exact = hadith16.text.substring(hadith16.text.length - 40);
      for (final r in [
        const SearchRequest(query: 'حلاوة الايمان'),
        const SearchRequest(query: 'ثلاث من كن فيه وجد حلاوة الايمان', mode: SearchMode.phrase),
        SearchRequest(query: exact, mode: SearchMode.exact),
      ]) {
        final ids = await search.hadithIds(r, offset: 0, limit: 500);
        expect(ids, contains(h16), reason: r.query);
      }
    });

    test('filters restrict results to a book and a chapter', () async {
      final h = (await repo.hadithsByNumber(16)).single;
      final inBook = await search.hadithIds(SearchRequest(query: 'الايمان', bookId: h.bookId), offset: 0, limit: 10000);
      final hadiths = await repo.hadithsByIds(inBook);
      expect(hadiths.every((x) => x.bookId == h.bookId), isTrue);
      final inChapter = await search.hadithIds(
        SearchRequest(query: 'الايمان', bookId: h.bookId, chapterId: h.chapterId),
        offset: 0,
        limit: 100,
      );
      expect(inChapter, [h.id]);
      expect(await search.countHadiths(SearchRequest(query: 'الايمان', bookId: h.bookId)), inBook.length);
    });

    test('pagination returns consecutive, non-overlapping pages', () async {
      const r = SearchRequest(query: 'رسول الله');
      final a = await search.hadithIds(r, offset: 0, limit: 20);
      final b = await search.hadithIds(r, offset: 20, limit: 20);
      expect(a.toSet().intersection(b.toSet()), isEmpty);
      expect((await search.hadithIds(r, offset: 0, limit: 40)), [...a, ...b]);
    });

    test('book and chapter names are searchable', () async {
      final hits = await search.headings(const SearchRequest(query: 'حلاوة الايمان'));
      final chapters = await repo.chaptersByIds([
        for (final h in hits)
          if (h.kind == 'chapter') h.refId,
      ]);
      expect(chapters.map((c) => c.heading), contains('٩ - بَابُ حَلَاوَةِ الْإِيمَانِ'));
    });
  });
}
