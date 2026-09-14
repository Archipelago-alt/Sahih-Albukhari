import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/content/content_models.dart';

/// One row of the continuous reader list.
sealed class ReaderEntry {
  const ReaderEntry();
}

class BookHeaderEntry extends ReaderEntry {
  const BookHeaderEntry(this.book);
  final Book book;
}

class ChapterHeaderEntry extends ReaderEntry {
  const ChapterHeaderEntry(this.chapter);
  final Chapter chapter;
}

class HadithEntry extends ReaderEntry {
  const HadithEntry({required this.hadithId, required this.uid, required this.chapterId, required this.ordinal});
  final int hadithId;
  final String uid;
  final int chapterId;

  /// Position among the hadiths of the book (0-based).
  final int ordinal;
}

class BookEndEntry extends ReaderEntry {
  const BookEndEntry(this.book);
  final Book book;
}

/// The structure of one book as the reader shows it: book heading, then
/// every chapter heading followed by exactly the hadiths the source places
/// beneath it, in source order. Hadith texts are loaded lazily in blocks.
class ReaderOutline {
  ReaderOutline._({
    required this.book,
    required this.chapters,
    required this.entries,
    required this.entryChapterId,
    required this.hadithIndex,
    required this.chapterIndex,
    required this.hadithIds,
    required this.notes,
  });

  static const int blockSize = 20;

  final Book book;
  final Map<int, Chapter> chapters;
  final List<ReaderEntry> entries;

  /// Chapter id in effect at each entry (null before the first chapter).
  final List<int?> entryChapterId;
  final Map<int, int> hadithIndex;
  final Map<int, int> chapterIndex;
  final List<int> hadithIds;

  /// Editor footnote markers of book/chapter texts, keyed by owner.
  final Map<(FootnoteOwner, int), List<FootnoteRef>> notes;

  List<FootnoteRef> notesOf(FootnoteOwner owner, int id) => notes[(owner, id)] ?? const [];

  Chapter? chapterAt(int index) {
    final id = entryChapterId[index.clamp(0, entries.length - 1)];
    return id == null ? null : chapters[id];
  }

  static ReaderOutline build({
    required Book book,
    required List<Chapter> chapters,
    required List<({int id, String uid, int chapterId})> hadiths,
    Map<(FootnoteOwner, int), List<FootnoteRef>> notes = const {},
  }) {
    final byChapter = <int, List<({int id, String uid, int chapterId})>>{};
    for (final h in hadiths) {
      byChapter.putIfAbsent(h.chapterId, () => []).add(h);
    }
    final sorted = [...chapters]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final entries = <ReaderEntry>[BookHeaderEntry(book)];
    final entryChapter = <int?>[null];
    final hadithIndex = <int, int>{};
    final chapterIndex = <int, int>{};
    final ids = <int>[];
    for (final c in sorted) {
      chapterIndex[c.id] = entries.length;
      if (!c.isImplicit) {
        entries.add(ChapterHeaderEntry(c));
        entryChapter.add(c.id);
      }
      for (final h in byChapter[c.id] ?? const <({int id, String uid, int chapterId})>[]) {
        hadithIndex[h.id] = entries.length;
        entries.add(HadithEntry(hadithId: h.id, uid: h.uid, chapterId: c.id, ordinal: ids.length));
        entryChapter.add(c.id);
        ids.add(h.id);
      }
    }
    if (ids.length != hadiths.length) {
      throw StateError('book ${book.uid}: ${hadiths.length - ids.length} hadith(s) without a chapter row');
    }
    entries.add(BookEndEntry(book));
    entryChapter.add(entryChapter.last);
    return ReaderOutline._(
      book: book,
      chapters: {for (final c in chapters) c.id: c},
      entries: entries,
      entryChapterId: entryChapter,
      hadithIndex: hadithIndex,
      chapterIndex: chapterIndex,
      hadithIds: ids,
      notes: notes,
    );
  }
}

final readerOutlineProvider = FutureProvider.family<ReaderOutline, int>((ref, bookId) async {
  final repo = ref.watch(contentRepositoryProvider);
  final book = await repo.book(bookId);
  final chapters = await repo.chaptersOfBook(bookId);
  final hadiths = await repo.hadithOutline(bookId);
  final notes = <(FootnoteOwner, int), List<FootnoteRef>>{};
  Future<void> load(FootnoteOwner owner, List<int> ids) async {
    for (final e in (await repo.footnotesFor(owner, ids)).entries) {
      notes[(owner, e.key)] = e.value;
    }
  }

  await load(FootnoteOwner.bookTitle, [bookId]);
  await load(FootnoteOwner.bookPreamble, [bookId]);
  await load(FootnoteOwner.bookIntro, [bookId]);
  final chapterIds = [for (final c in chapters) c.id];
  await load(FootnoteOwner.chapterTitle, chapterIds);
  await load(FootnoteOwner.chapterIntro, chapterIds);
  return ReaderOutline.build(book: book, chapters: chapters, hadiths: hadiths, notes: notes);
});

class LoadedHadith {
  const LoadedHadith(this.hadith, this.footnotes);
  final Hadith hadith;
  final List<FootnoteRef> footnotes;
}

/// Hadith texts of one block of a book, loaded on demand and released when
/// no longer on screen (keeps memory flat while browsing long books).
final hadithBlockProvider = FutureProvider.autoDispose.family<Map<int, LoadedHadith>, ({int bookId, int block})>((
  ref,
  key,
) async {
  final outline = await ref.watch(readerOutlineProvider(key.bookId).future);
  final start = key.block * ReaderOutline.blockSize;
  final ids = outline.hadithIds.sublist(start, (start + ReaderOutline.blockSize).clamp(0, outline.hadithIds.length));
  final repo = ref.watch(contentRepositoryProvider);
  final hadiths = await repo.hadithsByIds(ids);
  final notes = await repo.footnotesFor(FootnoteOwner.hadith, ids);
  return {for (final h in hadiths) h.id: LoadedHadith(h, notes[h.id] ?? const [])};
});
