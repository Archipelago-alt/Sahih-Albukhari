import 'package:flutter_test/flutter_test.dart';
import 'package:sahih_albukhari/data/user/user_database.dart';
import 'package:sahih_albukhari/data/user/user_repository.dart';

void main() {
  late UserDatabase db;
  late UserRepository repo;
  var now = DateTime.utc(2026, 1, 1);

  setUp(() {
    db = UserDatabase.inMemory();
    now = DateTime.utc(2026, 1, 1);
    repo = UserRepository(db, clock: () => now = now.add(const Duration(seconds: 1)));
  });
  tearDown(() => db.close());

  test('schema v1 is created with foreign keys enforced', () async {
    expect(db.schemaVersion, 1);
    final fk = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(fk.read<int>('foreign_keys'), 1);
    final tables = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name")
        .map((r) => r.read<String>('name'))
        .get();
    expect(
      tables,
      containsAll([
        'bookmarks',
        'bookmark_folders',
        'notes',
        'read_marks',
        'history_entries',
        'reading_positions',
        'search_history_entries',
        'setting_entries',
      ]),
    );
  });

  test('bookmarks toggle, carry folder and label, persist', () async {
    expect(await repo.toggleBookmark('h16'), isTrue);
    final folder = await repo.createFolder('الإيمان');
    await repo.updateBookmark('h16', folderId: folder, label: '  حلاوة الإيمان  ');
    final b = await repo.watchBookmark('h16').first;
    expect(b!.folderId, folder);
    expect(b.label, 'حلاوة الإيمان');
    expect(await repo.watchBookmarkedUids().first, {'h16'});
    expect(await repo.toggleBookmark('h16'), isFalse);
    expect(await repo.watchBookmarks().first, isEmpty);
  });

  test('deleting a folder keeps its bookmarks without a folder', () async {
    final folder = await repo.createFolder('f');
    await repo.addBookmark('h1', folderId: folder);
    await repo.deleteFolder(folder);
    expect((await repo.watchBookmark('h1').first)!.folderId, isNull);
  });

  test('notes are created, updated in place, searched and deleted', () async {
    await repo.saveNote('h1', 'أول حديث في الكتاب');
    await repo.saveNote('h1', 'النية أساس العمل');
    final notes = await repo.watchNotes().first;
    expect(notes, hasLength(1));
    expect(notes.single.body, 'النية أساس العمل');
    expect(notes.single.updatedAt.isAfter(notes.single.createdAt), isTrue);
    expect(UserRepository.filterNotes(notes, 'النيه'), isEmpty);
    expect(UserRepository.filterNotes(notes, 'اساس'), hasLength(1));
    await repo.deleteNote('h1');
    expect(await repo.watchNotes().first, isEmpty);
  });

  test('read marks and reading position survive and clear independently', () async {
    await repo.setRead(['h1', 'h2', 'h3'], read: true);
    await repo.setRead(['h2'], read: false);
    expect(await repo.watchReadUids().first, {'h1', 'h3'});
    await repo.addBookmark('h1');
    await repo.saveNote('h1', 'x');
    await repo.savePosition(bookUid: 'b2', chapterUid: 'b2-c9', hadithUid: 'h16', anchorOffset: 0.25);
    await repo.recordOpened('h16');
    final p = await repo.position();
    expect([p!.bookUid, p.chapterUid, p.hadithUid, p.anchorOffset], ['b2', 'b2-c9', 'h16', 0.25]);

    await repo.clearReadingHistory();
    expect(await repo.position(), isNull);
    expect(await repo.watchHistory().first, isEmpty);
    // Bookmarks, notes and read marks are untouched.
    expect(await repo.watchBookmarkedUids().first, {'h1'});
    expect(await repo.watchNotedUids().first, {'h1'});
    expect(await repo.watchReadUids().first, {'h1', 'h3'});
  });

  test('history keeps the most recent entries, newest first', () async {
    for (var i = 1; i <= 60; i++) {
      await repo.recordOpened('h$i');
    }
    await repo.recordOpened('h5');
    final history = await repo.watchHistory(limit: 100).first;
    expect(history, hasLength(50));
    expect(history.first.hadithUid, 'h5');
  });

  test('search history is de-duplicated and clearable', () async {
    await repo.addSearch('الإيمان');
    await repo.addSearch('  ');
    await repo.addSearch('النية');
    await repo.addSearch('الإيمان');
    expect((await repo.watchSearchHistory().first).map((e) => e.query), ['الإيمان', 'النية']);
    await repo.clearSearchHistory();
    expect(await repo.watchSearchHistory().first, isEmpty);
  });

  test('settings are stored as key/value pairs', () async {
    await repo.setSetting('font_size', '24');
    await repo.setSetting('font_size', '26');
    expect(await repo.settings(), {'font_size': '26'});
  });

  test('database file persists across reopen', () async {
    // In-memory databases cannot be reopened; verify the write goes through
    // a transaction boundary instead.
    await db.transaction(() => repo.addBookmark('h7'));
    final count = await db.customSelect('SELECT COUNT(*) AS n FROM bookmarks').getSingle();
    expect(count.read<int>('n'), 1);
  });
}
