import 'dart:convert';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:sahih_albukhari/data/user/user_database.dart';
import 'package:sahih_albukhari/data/user/user_repository.dart';
import 'package:sahih_albukhari/features/backup/backup_service.dart';

void main() {
  late UserDatabase db;
  late UserRepository repo;
  late BackupService backup;
  final known = {'h1', 'h16', 'h7559'};
  final structure = {'b1', 'b2', 'b2-c9'};

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() {
    db = UserDatabase.inMemory();
    repo = UserRepository(db);
    backup = BackupService(db, clock: () => DateTime.utc(2026, 9, 14));
  });
  tearDown(() => db.close());

  Future<String> exportAll() => backup.export(
    sections: BackupSection.values.toSet(),
    appVersion: '1.0.0+1',
    contentSha256: 'abc',
    numberByUid: {'h1': '١', 'h16': '١٦', 'h7559': '٧٥٥٩'},
  );

  BackupData parse(String json) => backup.parse(json, knownHadithUids: known, knownStructureUids: structure);

  test('export is versioned, human readable and contains no hadith text', () async {
    final folder = await repo.createFolder('مجلد');
    await repo.addBookmark('h16', folderId: folder, label: 'حلاوة الإيمان');
    await repo.saveNote('h1', 'ملاحظة');
    final json = jsonDecode(await exportAll()) as Map<String, dynamic>;
    expect(json['format'], BackupService.format);
    expect(json['schema_version'], 1);
    expect(((json['bookmarks'] as List).single as Map<String, dynamic>)['hadith_number'], '١٦');
    expect(((json['notes'] as List).single as Map<String, dynamic>)['body'], 'ملاحظة');
    expect(json.keys, isNot(contains('text')));
  });

  test('round trip restores every section', () async {
    final folder = await repo.createFolder('مجلد');
    await repo.addBookmark('h16', folderId: folder, label: 'وصف');
    await repo.saveNote('h1', 'ملاحظة');
    await repo.setRead(['h1', 'h16'], read: true);
    await repo.recordOpened('h16');
    await repo.savePosition(bookUid: 'b2', chapterUid: 'b2-c9', hadithUid: 'h16', anchorOffset: 0.4);
    await repo.setSetting('font_size', '26');
    final json = await exportAll();

    final other = UserDatabase.inMemory();
    addTearDown(other.close);
    await UserRepository(other).addBookmark('h7559');
    final summary = await BackupService(other)
        .restore(BackupService(other).parse(json, knownHadithUids: known, knownStructureUids: structure));
    expect(summary.bookmarks, 1);
    final r2 = UserRepository(other);
    final b = await r2.watchBookmark('h16').first;
    expect(b!.label, 'وصف');
    expect((await r2.watchFolders().first).single.name, 'مجلد');
    expect(await r2.watchBookmarkedUids().first, {'h16'}, reason: 'bookmarks section replaced');
    expect((await r2.watchNote('h1').first)!.body, 'ملاحظة');
    expect(await r2.watchReadUids().first, {'h1', 'h16'});
    expect((await r2.position())!.anchorOffset, 0.4);
    expect(await r2.settings(), {'font_size': '26'});
  });

  test('sections absent from the file are left untouched', () async {
    await repo.saveNote('h1', 'محلية');
    final json = await backup.export(
      sections: {BackupSection.bookmarks},
      appVersion: '1',
      contentSha256: 'abc',
      numberByUid: const {},
    );
    await backup.restore(parse(json));
    expect((await repo.watchNote('h1').first)!.body, 'محلية');
  });

  test('rejects invalid files with precise problems', () {
    expect(() => parse('not json'), throwsA(isA<BackupFormatException>()));
    expect(
      () => parse(jsonEncode({'format': 'other', 'schema_version': 1})),
      throwsA(isA<BackupFormatException>().having((e) => e.problems.first, 'problem', contains('format'))),
    );
    expect(
      () => parse(jsonEncode({'format': BackupService.format, 'schema_version': 99, 'notes': []})),
      throwsA(isA<BackupFormatException>().having((e) => e.problems.first, 'problem', contains('not supported'))),
    );
    final bad = {
      'format': BackupService.format,
      'schema_version': 1,
      'bookmark_folders': [],
      'bookmarks': [
        {'hadith_uid': 'h99999', 'folder_id': 3, 'created_at': 'x', 'updated_at': '2026-01-01T00:00:00Z'},
      ],
    };
    expect(
      () => parse(jsonEncode(bad)),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.problems,
          'problems',
          containsAll([
            'bookmarks[0].hadith_uid: "h99999" does not exist in this edition',
            'bookmarks[0].folder_id: unknown folder',
            'bookmarks[0].created_at: invalid date',
          ]),
        ),
      ),
    );
  });
}
