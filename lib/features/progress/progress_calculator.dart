/// Reading progress derived only from hadiths the reader marked as read
/// (or that were marked automatically while reading). No estimates.
class ReadingProgress {
  const ReadingProgress(this.read, this.total);

  static const empty = ReadingProgress(0, 0);

  final int read;
  final int total;

  double get fraction => total == 0 ? 0 : read / total;

  /// Whole-number percentage, rounded down so 100% means everything.
  int get percent => total == 0 ? 0 : (read * 100) ~/ total;

  bool get isComplete => total > 0 && read >= total;

  @override
  bool operator ==(Object other) => other is ReadingProgress && other.read == read && other.total == total;

  @override
  int get hashCode => Object.hash(read, total);

  @override
  String toString() => 'ReadingProgress($read/$total)';
}

class ProgressSummary {
  const ProgressSummary({required this.overall, required this.byBook});

  final ReadingProgress overall;
  final Map<int, ReadingProgress> byBook;
}

abstract final class ProgressCalculator {
  /// [readUids]: hadiths marked read. [bookOfUid]: book id of every hadith
  /// uid in the collection. [hadithCountByBook]: hadith total per book.
  /// Read marks for uids unknown to the collection are ignored.
  static ProgressSummary compute({
    required Set<String> readUids,
    required Map<String, int> bookOfUid,
    required Map<int, int> hadithCountByBook,
  }) {
    final readByBook = <int, int>{};
    var read = 0;
    for (final uid in readUids) {
      final book = bookOfUid[uid];
      if (book == null) continue;
      readByBook[book] = (readByBook[book] ?? 0) + 1;
      read++;
    }
    final total = hadithCountByBook.values.fold<int>(0, (a, b) => a + b);
    return ProgressSummary(
      overall: ReadingProgress(read, total),
      byBook: {for (final e in hadithCountByBook.entries) e.key: ReadingProgress(readByBook[e.key] ?? 0, e.value)},
    );
  }
}
