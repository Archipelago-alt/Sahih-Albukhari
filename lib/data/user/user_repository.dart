import 'package:drift/drift.dart';

import '../../core/arabic/arabic_normalizer.dart';
import 'user_database.dart';

export 'user_database.dart' show Bookmark, BookmarkFolder, HistoryEntry, Note, ReadingPosition, SearchHistoryEntry;

enum BookmarkSort { newest, oldest, canonical }

/// All reads and writes of private user data. Nothing here touches the
/// canonical content.
class UserRepository {
  UserRepository(this.db, {DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  final UserDatabase db;
  final DateTime Function() _now;

  static const int _historyLimit = 50;
  static const int _searchHistoryLimit = 30;

  // ------------------------------------------------------------ bookmarks

  Stream<List<Bookmark>> watchBookmarks() =>
      (db.select(db.bookmarks)..orderBy([(b) => OrderingTerm.desc(b.createdAt)])).watch();

  Stream<Set<String>> watchBookmarkedUids() =>
      db.select(db.bookmarks).map((b) => b.hadithUid).watch().map((l) => l.toSet());

  Stream<Bookmark?> watchBookmark(String hadithUid) =>
      (db.select(db.bookmarks)..where((b) => b.hadithUid.equals(hadithUid))).watchSingleOrNull();

  Future<void> addBookmark(String hadithUid, {int? folderId, String? label}) {
    final now = _now();
    return db
        .into(db.bookmarks)
        .insert(
          BookmarksCompanion(
            hadithUid: Value(hadithUid),
            folderId: Value(folderId),
            label: Value(_clean(label)),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
          onConflict: DoUpdate(
            (old) => BookmarksCompanion(folderId: Value(folderId), label: Value(_clean(label)), updatedAt: Value(now)),
            target: [db.bookmarks.hadithUid],
          ),
        );
  }

  Future<void> updateBookmark(String hadithUid, {int? folderId, String? label}) =>
      (db.update(db.bookmarks)..where((b) => b.hadithUid.equals(hadithUid))).write(
        BookmarksCompanion(folderId: Value(folderId), label: Value(_clean(label)), updatedAt: Value(_now())),
      );

  Future<void> removeBookmark(String hadithUid) =>
      (db.delete(db.bookmarks)..where((b) => b.hadithUid.equals(hadithUid))).go();

  /// Returns true when the hadith is bookmarked after the call.
  Future<bool> toggleBookmark(String hadithUid) => db.transaction(() async {
    final existing = await (db.select(db.bookmarks)..where((b) => b.hadithUid.equals(hadithUid))).getSingleOrNull();
    if (existing != null) {
      await removeBookmark(hadithUid);
      return false;
    }
    await addBookmark(hadithUid);
    return true;
  });

  Stream<List<BookmarkFolder>> watchFolders() => (db.select(
    db.bookmarkFolders,
  )..orderBy([(f) => OrderingTerm.asc(f.sortOrder), (f) => OrderingTerm.asc(f.name)])).watch();

  Future<int> createFolder(String name) =>
      db.into(db.bookmarkFolders).insert(BookmarkFoldersCompanion(name: Value(name.trim()), createdAt: Value(_now())));

  Future<void> renameFolder(int id, String name) => (db.update(
    db.bookmarkFolders,
  )..where((f) => f.id.equals(id))).write(BookmarkFoldersCompanion(name: Value(name.trim())));

  /// Deletes the folder; its bookmarks are kept without a folder.
  Future<void> deleteFolder(int id) => (db.delete(db.bookmarkFolders)..where((f) => f.id.equals(id))).go();

  // ---------------------------------------------------------------- notes

  Stream<List<Note>> watchNotes() => (db.select(db.notes)..orderBy([(n) => OrderingTerm.desc(n.updatedAt)])).watch();

  Stream<Note?> watchNote(String hadithUid) =>
      (db.select(db.notes)..where((n) => n.hadithUid.equals(hadithUid))).watchSingleOrNull();

  Stream<Set<String>> watchNotedUids() => db.select(db.notes).map((n) => n.hadithUid).watch().map((l) => l.toSet());

  Future<void> saveNote(String hadithUid, String body) {
    final now = _now();
    return db
        .into(db.notes)
        .insert(
          NotesCompanion(hadithUid: Value(hadithUid), body: Value(body), createdAt: Value(now), updatedAt: Value(now)),
          onConflict: DoUpdate(
            (old) => NotesCompanion(body: Value(body), updatedAt: Value(now)),
            target: [db.notes.hadithUid],
          ),
        );
  }

  Future<void> deleteNote(String hadithUid) => (db.delete(db.notes)..where((n) => n.hadithUid.equals(hadithUid))).go();

  /// Notes whose text contains every word of [query] (normalized, so
  /// diacritics and alef/yaa variants do not matter).
  static List<Note> filterNotes(List<Note> notes, String query) {
    final words = ArabicNormalizer.normalize(query).split(' ').where((w) => w.isNotEmpty);
    if (words.isEmpty) return notes;
    return [
      for (final n in notes)
        if (words.every(ArabicNormalizer.normalize(n.body).contains)) n,
    ];
  }

  // -------------------------------------------------------- read / progress

  Stream<Set<String>> watchReadUids() => db.select(db.readMarks).map((r) => r.hadithUid).watch().map((l) => l.toSet());

  Future<void> setRead(Iterable<String> hadithUids, {required bool read}) async {
    final uids = hadithUids.toList();
    if (uids.isEmpty) return;
    if (!read) {
      await (db.delete(db.readMarks)..where((r) => r.hadithUid.isIn(uids))).go();
      return;
    }
    final now = _now();
    await db.batch((b) {
      b.insertAllOnConflictUpdate(db.readMarks, [
        for (final u in uids) ReadMarksCompanion(hadithUid: Value(u), readAt: Value(now)),
      ]);
    });
  }

  Future<void> clearReadMarks() => db.delete(db.readMarks).go();

  // -------------------------------------------------------------- history

  Stream<List<HistoryEntry>> watchHistory({int limit = 20}) =>
      (db.select(db.historyEntries)
            ..orderBy([(h) => OrderingTerm.desc(h.openedAt)])
            ..limit(limit))
          .watch();

  Future<void> recordOpened(String hadithUid) => db.transaction(() async {
    await db
        .into(db.historyEntries)
        .insertOnConflictUpdate(HistoryEntriesCompanion(hadithUid: Value(hadithUid), openedAt: Value(_now())));
    await db.customStatement(
      'DELETE FROM history_entries WHERE hadith_uid NOT IN '
      '(SELECT hadith_uid FROM history_entries ORDER BY opened_at DESC LIMIT $_historyLimit)',
    );
  });

  /// Clears recently opened hadiths and the saved reading position.
  /// Bookmarks, notes and read marks are not affected.
  Future<void> clearReadingHistory() => db.transaction(() async {
    await db.delete(db.historyEntries).go();
    await db.delete(db.readingPositions).go();
  });

  // ------------------------------------------------------------- position

  Stream<ReadingPosition?> watchPosition() =>
      (db.select(db.readingPositions)..where((p) => p.id.equals(1))).watchSingleOrNull();

  Future<ReadingPosition?> position() =>
      (db.select(db.readingPositions)..where((p) => p.id.equals(1))).getSingleOrNull();

  Future<void> savePosition({
    required String bookUid,
    String? chapterUid,
    String? hadithUid,
    double anchorOffset = 0,
  }) => db
      .into(db.readingPositions)
      .insertOnConflictUpdate(
        ReadingPositionsCompanion(
          id: const Value(1),
          bookUid: Value(bookUid),
          chapterUid: Value(chapterUid),
          hadithUid: Value(hadithUid),
          anchorOffset: Value(anchorOffset),
          updatedAt: Value(_now()),
        ),
      );

  // ------------------------------------------------------- search history

  Stream<List<SearchHistoryEntry>> watchSearchHistory() =>
      (db.select(db.searchHistoryEntries)
            ..orderBy([(s) => OrderingTerm.desc(s.searchedAt)])
            ..limit(_searchHistoryLimit))
          .watch();

  Future<void> addSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    await db.transaction(() async {
      await db
          .into(db.searchHistoryEntries)
          .insertOnConflictUpdate(SearchHistoryEntriesCompanion(query: Value(q), searchedAt: Value(_now())));
      await db.customStatement(
        'DELETE FROM search_history_entries WHERE query NOT IN '
        '(SELECT query FROM search_history_entries ORDER BY searched_at DESC '
        'LIMIT $_searchHistoryLimit)',
      );
    });
  }

  Future<void> removeSearch(String query) =>
      (db.delete(db.searchHistoryEntries)..where((s) => s.query.equals(query))).go();

  Future<void> clearSearchHistory() => db.delete(db.searchHistoryEntries).go();

  // ------------------------------------------------------------- settings

  Future<Map<String, String>> settings() async => {
    for (final s in await db.select(db.settingEntries).get()) s.key: s.value,
  };

  Future<void> setSetting(String key, String value) =>
      db.into(db.settingEntries).insertOnConflictUpdate(SettingEntriesCompanion(key: Value(key), value: Value(value)));

  static String? _clean(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}
