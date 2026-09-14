import 'package:drift/drift.dart';

import 'content_database.dart';
import 'content_models.dart';

/// Read-only access to books, chapters and hadiths.
class ContentRepository {
  ContentRepository(this._db);

  final ContentDatabase _db;

  static const _bookColumns =
      'id, uid, sort_order, number, number_text, title, '
      'heading, preamble, intro, volume, printed_page, chapter_count, '
      'hadith_count, first_hadith_id, last_hadith_id';
  static const _chapterColumns =
      'id, uid, book_id, parent_id, depth, '
      'sort_order, is_implicit, number, number_text, title, heading, intro, '
      'volume, printed_page, hadith_count, first_hadith_id, last_hadith_id';
  static const _hadithColumns =
      'id, uid, sort_order, book_id, chapter_id, '
      'number, number_end, number_text, text, spans, volume, printed_page_start, '
      'printed_page_end, tuhfa';

  Future<List<QueryRow>> _select(String sql, [List<Object?> args = const []]) =>
      _db.customSelect(sql, variables: [for (final a in args) _variable(a)]).get();

  static Variable<Object> _variable(Object? value) => switch (value) {
    final int v => Variable.withInt(v),
    final String v => Variable.withString(v),
    _ => throw ArgumentError.value(value, 'value', 'unsupported type'),
  };

  static String _placeholders(int n) => List.filled(n, '?').join(',');

  Future<ContentInfo> info() async {
    final rows = await _select('SELECT key, value FROM meta');
    return ContentInfo({for (final r in rows) r.read<String>('key'): r.read<String>('value')});
  }

  Future<int> schemaVersion() async => (await _select('PRAGMA user_version')).single.read<int>('user_version');

  Future<int> totalHadithCount() async => (await _select('SELECT COUNT(*) AS n FROM hadiths')).single.read<int>('n');

  // ---------------------------------------------------------------- books

  Future<List<Book>> books() async =>
      (await _select('SELECT $_bookColumns FROM books ORDER BY sort_order')).map(_book).toList();

  Future<Book> book(int id) async =>
      _book((await _select('SELECT $_bookColumns FROM books WHERE id = ?', [id])).single);

  // ------------------------------------------------------------- chapters

  Future<List<Chapter>> chaptersOfBook(int bookId) async => (await _select(
    'SELECT $_chapterColumns FROM chapters WHERE book_id = ? ORDER BY sort_order',
    [bookId],
  )).map(_chapter).toList();

  Future<Chapter> chapter(int id) async =>
      _chapter((await _select('SELECT $_chapterColumns FROM chapters WHERE id = ?', [id])).single);

  // -------------------------------------------------------------- hadiths

  /// Ordered (hadith id, uid, chapter id) of a book: the reader's skeleton.
  Future<List<({int id, String uid, int chapterId})>> hadithOutline(int bookId) async => [
    for (final r in await _select('SELECT id, uid, chapter_id FROM hadiths WHERE book_id = ? ORDER BY sort_order', [
      bookId,
    ]))
      (id: r.read<int>('id'), uid: r.read<String>('uid'), chapterId: r.read<int>('chapter_id')),
  ];

  Future<List<Chapter>> chaptersByIds(List<int> ids) async {
    if (ids.isEmpty) return const [];
    return (await _select(
      'SELECT $_chapterColumns FROM chapters WHERE id IN (${_placeholders(ids.length)})',
      ids,
    )).map(_chapter).toList();
  }

  Future<List<Hadith>> hadithsByIds(List<int> ids) async {
    if (ids.isEmpty) return const [];
    final rows = await _select(
      'SELECT $_hadithColumns FROM hadiths WHERE id IN (${_placeholders(ids.length)}) '
      'ORDER BY sort_order',
      ids,
    );
    return rows.map(_hadith).toList();
  }

  Future<Hadith?> hadith(int id) async => (await hadithsByIds([id])).firstOrNull;

  Future<List<Hadith>> hadithsByUids(List<String> uids) async {
    if (uids.isEmpty) return const [];
    final rows = await _select(
      'SELECT $_hadithColumns FROM hadiths WHERE uid IN (${_placeholders(uids.length)}) '
      'ORDER BY sort_order',
      uids,
    );
    return rows.map(_hadith).toList();
  }

  /// Hadiths carrying the printed number [number] (normally exactly one;
  /// a record printed under two numbers matches either).
  Future<List<Hadith>> hadithsByNumber(int number) async => (await _select(
    'SELECT $_hadithColumns FROM hadiths '
    'WHERE number = ?1 OR (number_end IS NOT NULL AND ?1 BETWEEN number AND number_end) '
    'ORDER BY sort_order',
    [number],
  )).map(_hadith).toList();

  /// The hadith immediately before/after [hadithId] in collection order.
  Future<Hadith?> neighbour(int hadithId, {required bool next}) async {
    final op = next ? '>' : '<';
    final dir = next ? 'ASC' : 'DESC';
    final rows = await _select(
      'SELECT $_hadithColumns FROM hadiths WHERE sort_order $op '
      '(SELECT sort_order FROM hadiths WHERE id = ?) ORDER BY sort_order $dir LIMIT 1',
      [hadithId],
    );
    return rows.map(_hadith).firstOrNull;
  }

  /// Book id of every hadith uid (for progress calculations).
  Future<Map<String, int>> bookOfHadithUid() async => {
    for (final r in await _select('SELECT uid, book_id FROM hadiths')) r.read<String>('uid'): r.read<int>('book_id'),
  };

  /// Printed number of every hadith uid (for human-readable backups).
  Future<Map<String, String>> numberOfHadithUid() async => {
    for (final r in await _select('SELECT uid, number_text FROM hadiths'))
      r.read<String>('uid'): r.read<String>('number_text'),
  };

  /// Uids of all books and chapters (for validating restored positions).
  Future<Set<String>> structureUids() async => {
    for (final r in await _select('SELECT uid FROM books UNION ALL SELECT uid FROM chapters')) r.read<String>('uid'),
  };

  Future<Book?> bookByUid(String uid) async =>
      (await _select('SELECT $_bookColumns FROM books WHERE uid = ?', [uid])).map(_book).firstOrNull;

  Future<Chapter?> chapterByUid(String uid) async =>
      (await _select('SELECT $_chapterColumns FROM chapters WHERE uid = ?', [uid])).map(_chapter).firstOrNull;

  /// Hadith uids of one chapter, in order (for "mark chapter as read").
  Future<List<String>> hadithUidsOfChapter(int chapterId) async => [
    for (final r in await _select('SELECT uid FROM hadiths WHERE chapter_id = ? ORDER BY sort_order', [chapterId]))
      r.read<String>('uid'),
  ];

  /// Number of hadiths per book (for progress calculations).
  Future<Map<int, int>> hadithCountsByBook() async => {
    for (final r in await _select('SELECT id, hadith_count FROM books')) r.read<int>('id'): r.read<int>('hadith_count'),
  };

  // -------------------------------------------------------------- mapping

  static Book _book(QueryRow r) => Book(
    id: r.read<int>('id'),
    uid: r.read<String>('uid'),
    sortOrder: r.read<int>('sort_order'),
    number: r.readNullable<int>('number'),
    numberText: r.readNullable<String>('number_text'),
    title: r.read<String>('title'),
    heading: r.read<String>('heading'),
    preamble: r.readNullable<String>('preamble'),
    intro: r.readNullable<String>('intro'),
    volume: r.readNullable<int>('volume'),
    printedPage: r.readNullable<String>('printed_page'),
    chapterCount: r.read<int>('chapter_count'),
    hadithCount: r.read<int>('hadith_count'),
    firstHadithId: r.readNullable<int>('first_hadith_id'),
    lastHadithId: r.readNullable<int>('last_hadith_id'),
  );

  static Chapter _chapter(QueryRow r) => Chapter(
    id: r.read<int>('id'),
    uid: r.read<String>('uid'),
    bookId: r.read<int>('book_id'),
    parentId: r.readNullable<int>('parent_id'),
    depth: r.read<int>('depth'),
    sortOrder: r.read<int>('sort_order'),
    isImplicit: r.read<int>('is_implicit') == 1,
    number: r.readNullable<int>('number'),
    numberText: r.readNullable<String>('number_text'),
    title: r.readNullable<String>('title'),
    heading: r.readNullable<String>('heading'),
    intro: r.readNullable<String>('intro'),
    volume: r.readNullable<int>('volume'),
    printedPage: r.readNullable<String>('printed_page'),
    hadithCount: r.read<int>('hadith_count'),
    firstHadithId: r.readNullable<int>('first_hadith_id'),
    lastHadithId: r.readNullable<int>('last_hadith_id'),
  );

  static Hadith _hadith(QueryRow r) => Hadith(
    id: r.read<int>('id'),
    uid: r.read<String>('uid'),
    sortOrder: r.read<int>('sort_order'),
    bookId: r.read<int>('book_id'),
    chapterId: r.read<int>('chapter_id'),
    number: r.readNullable<int>('number'),
    numberEnd: r.readNullable<int>('number_end'),
    numberText: r.read<String>('number_text'),
    text: r.read<String>('text'),
    spans: StyleSpan.decodeList(r.read<String>('spans')),
    volume: r.readNullable<int>('volume'),
    printedPageStart: r.readNullable<String>('printed_page_start'),
    printedPageEnd: r.readNullable<String>('printed_page_end'),
    tuhfa: r.readNullable<String>('tuhfa'),
  );
}
