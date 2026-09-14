import 'package:drift/drift.dart';

import '../../core/arabic/arabic_normalizer.dart';
import 'content_database.dart';

enum SearchMode {
  /// Every entered word must appear (in any order).
  allWords,

  /// The entered words must appear together, in order.
  phrase,

  /// Character-for-character match against the original text, including
  /// diacritics (no normalization).
  exact,
}

class SearchRequest {
  const SearchRequest({
    required this.query,
    this.mode = SearchMode.allWords,
    this.broad = false,
    this.wholeWords = false,
    this.bookId,
    this.chapterId,
  });

  final String query;
  final SearchMode mode;

  /// Also treat ة and ه as the same letter.
  final bool broad;

  /// Match whole words only (otherwise a word may be part of a longer word,
  /// e.g. "الايمان" in "بالايمان").
  final bool wholeWords;
  final int? bookId;
  final int? chapterId;

  String get normalized => ArabicNormalizer.normalize(query, broad: broad);

  List<String> get tokens => normalized.split(' ').where((t) => t.isNotEmpty).toList();

  /// The query is a plain hadith number (Arabic or Western digits).
  int? get hadithNumber {
    final digits = ArabicNormalizer.toWesternDigits(query.trim());
    return RegExp(r'^\d{1,5}$').hasMatch(digits) ? int.parse(digits) : null;
  }

  bool get isEmpty => mode == SearchMode.exact ? query.trim().isEmpty : tokens.isEmpty;

  SearchRequest copyWith({
    String? query,
    SearchMode? mode,
    bool? broad,
    bool? wholeWords,
    int? Function()? bookId,
    int? Function()? chapterId,
  }) => SearchRequest(
    query: query ?? this.query,
    mode: mode ?? this.mode,
    broad: broad ?? this.broad,
    wholeWords: wholeWords ?? this.wholeWords,
    bookId: bookId != null ? bookId() : this.bookId,
    chapterId: chapterId != null ? chapterId() : this.chapterId,
  );

  @override
  bool operator ==(Object other) =>
      other is SearchRequest &&
      other.query == query &&
      other.mode == mode &&
      other.broad == broad &&
      other.wholeWords == wholeWords &&
      other.bookId == bookId &&
      other.chapterId == chapterId;

  @override
  int get hashCode => Object.hash(query, mode, broad, wholeWords, bookId, chapterId);
}

class HeadingHit {
  const HeadingHit({required this.kind, required this.refId, required this.bookId});

  /// 'book' or 'chapter'.
  final String kind;
  final int refId;
  final int bookId;
}

/// Offline search over the precomputed, search-only normalized text.
///
/// Queries scan the `hadith_search` table with `instr()`, which supports
/// matching inside words (Arabic attaches prefixes such as و ف ب ك ل ال to
/// words) as well as whole-word matching. The work runs on the database's
/// background isolate. Timings are documented in docs/PERFORMANCE.md.
class SearchRepository {
  SearchRepository(this._db);

  final ContentDatabase _db;

  ({String where, List<Variable<Object>> vars}) _filter(SearchRequest r) {
    final where = <String>[];
    final vars = <Variable<Object>>[];
    final column = r.broad ? 's.norm_broad' : 's.norm';
    String contains(String col, String needle) {
      if (r.wholeWords) {
        vars.add(Variable.withString(' $needle '));
        return "instr(' ' || $col || ' ', ?) > 0";
      }
      vars.add(Variable.withString(needle));
      return 'instr($col, ?) > 0';
    }

    switch (r.mode) {
      case SearchMode.exact:
        vars.add(Variable.withString(r.query.trim()));
        where.add('instr(h.text, ?) > 0');
      case SearchMode.phrase:
        where.add(contains(column, r.normalized));
      case SearchMode.allWords:
        for (final t in r.tokens.toSet()) {
          where.add(contains(column, t));
        }
    }
    if (r.bookId != null) {
      where.add('h.book_id = ?');
      vars.add(Variable.withInt(r.bookId!));
    }
    if (r.chapterId != null) {
      where.add('h.chapter_id = ?');
      vars.add(Variable.withInt(r.chapterId!));
    }
    return (where: where.join(' AND '), vars: vars);
  }

  Future<int> countHadiths(SearchRequest r) async {
    if (r.isEmpty) return 0;
    final f = _filter(r);
    final row = await _db
        .customSelect(
          'SELECT COUNT(*) AS n FROM hadiths h JOIN hadith_search s ON s.id = h.id '
          'WHERE ${f.where}',
          variables: f.vars,
        )
        .getSingle();
    return row.read<int>('n');
  }

  /// Matching hadith ids in collection order, one page at a time.
  Future<List<int>> hadithIds(SearchRequest r, {required int offset, required int limit}) async {
    if (r.isEmpty) return const [];
    final f = _filter(r);
    final rows = await _db
        .customSelect(
          'SELECT h.id FROM hadiths h JOIN hadith_search s ON s.id = h.id '
          'WHERE ${f.where} ORDER BY h.sort_order LIMIT ? OFFSET ?',
          variables: [...f.vars, Variable.withInt(limit), Variable.withInt(offset)],
        )
        .get();
    return [for (final row in rows) row.read<int>('id')];
  }

  /// Books and chapters whose names match (exact mode uses the original
  /// heading text).
  Future<List<HeadingHit>> headings(SearchRequest r, {int limit = 100}) async {
    if (r.isEmpty) return const [];
    final column = r.broad ? 'norm_broad' : 'norm';
    final where = <String>[];
    final vars = <Variable<Object>>[];
    String sql;
    if (r.mode == SearchMode.exact) {
      vars.add(Variable.withString(r.query.trim()));
      sql = '''
        SELECT 'book' AS kind, id AS ref_id, id AS book_id, sort_order AS o
          FROM books WHERE instr(title, ?1) > 0
        UNION ALL
        SELECT 'chapter', id, book_id, 100000 + sort_order
          FROM chapters WHERE title IS NOT NULL AND instr(title, ?1) > 0
        ORDER BY o LIMIT ?2''';
      vars.add(Variable.withInt(limit));
    } else {
      final needles = r.mode == SearchMode.phrase ? [r.normalized] : r.tokens.toSet();
      for (final n in needles) {
        if (r.wholeWords) {
          where.add("instr(' ' || $column || ' ', ?) > 0");
          vars.add(Variable.withString(' $n '));
        } else {
          where.add('instr($column, ?) > 0');
          vars.add(Variable.withString(n));
        }
      }
      if (r.bookId != null) {
        where.add('book_id = ?');
        vars.add(Variable.withInt(r.bookId!));
      }
      sql =
          'SELECT kind, ref_id, book_id FROM heading_search '
          'WHERE ${where.join(' AND ')} ORDER BY id LIMIT ?';
      vars.add(Variable.withInt(limit));
    }
    final rows = await _db.customSelect(sql, variables: vars).get();
    return [
      for (final row in rows)
        HeadingHit(kind: row.read<String>('kind'), refId: row.read<int>('ref_id'), bookId: row.read<int>('book_id')),
    ];
  }
}
