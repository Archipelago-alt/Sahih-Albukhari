import '../../data/content/search_repository.dart';

/// Where the reader should open: a book, optionally scrolled to a chapter
/// or hadith, optionally highlighting a search.
class ReaderTarget {
  const ReaderTarget({required this.bookId, this.chapterId, this.hadithId, this.anchorOffset = 0, this.highlight});

  final int bookId;
  final int? chapterId;
  final int? hadithId;

  /// Fraction of the anchor item already scrolled past (position restore).
  final double anchorOffset;
  final SearchRequest? highlight;

  String get location {
    final q = <String, String>{
      if (chapterId != null) 'chapter': '$chapterId',
      if (hadithId != null) 'hadith': '$hadithId',
      if (anchorOffset != 0) 'offset': anchorOffset.toStringAsFixed(4),
      if (highlight != null) ...{
        'q': highlight!.query,
        'mode': highlight!.mode.name,
        if (highlight!.broad) 'broad': '1',
        if (highlight!.wholeWords) 'whole': '1',
      },
    };
    return Uri(path: '/read/$bookId', queryParameters: q.isEmpty ? null : q).toString();
  }

  static ReaderTarget fromUri(int bookId, Map<String, String> q) {
    final query = q['q'];
    return ReaderTarget(
      bookId: bookId,
      chapterId: int.tryParse(q['chapter'] ?? ''),
      hadithId: int.tryParse(q['hadith'] ?? ''),
      anchorOffset: double.tryParse(q['offset'] ?? '') ?? 0,
      highlight: query == null || query.isEmpty
          ? null
          : SearchRequest(
              query: query,
              mode: SearchMode.values.where((m) => m.name == q['mode']).firstOrNull ?? SearchMode.allWords,
              broad: q['broad'] == '1',
              wholeWords: q['whole'] == '1',
            ),
    );
  }
}
