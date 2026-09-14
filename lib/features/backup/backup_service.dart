import 'dart:convert';

import 'package:drift/drift.dart';

import '../../data/user/user_database.dart';

/// Which parts of the user data a backup contains.
enum BackupSection { bookmarks, notes, progress, history, settings }

/// Thrown when a backup file cannot be restored. [problems] lists every
/// problem found, with the JSON path it concerns.
class BackupFormatException implements Exception {
  BackupFormatException(this.problems);

  final List<String> problems;

  @override
  String toString() => 'BackupFormatException(${problems.join('; ')})';
}

class RestoreSummary {
  const RestoreSummary({
    required this.folders,
    required this.bookmarks,
    required this.notes,
    required this.readMarks,
    required this.history,
    required this.settings,
  });

  final int folders;
  final int bookmarks;
  final int notes;
  final int readMarks;
  final int history;
  final int settings;
}

/// A validated, not yet applied backup.
class BackupData {
  BackupData._(this.sections, this._json);

  final Set<BackupSection> sections;
  final Map<String, dynamic> _json;

  int count(String key) => (_json[key] as List?)?.length ?? 0;
}

/// JSON backup and restore of private user data.
///
/// The file never contains hadith text: hadiths are referenced by their
/// stable uid (plus the printed number, for people reading the file).
class BackupService {
  BackupService(this._db, {DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  static const String format = 'sahih-albukhari-reader-backup';
  static const int schemaVersion = 1;

  final UserDatabase _db;
  final DateTime Function() _now;

  Future<String> export({
    required Set<BackupSection> sections,
    required String appVersion,
    required String contentSha256,
    required Map<String, String> numberByUid,
  }) async {
    String iso(DateTime d) => d.toUtc().toIso8601String();
    final out = <String, dynamic>{
      'format': format,
      'schema_version': schemaVersion,
      'exported_at': iso(_now()),
      'app_version': appVersion,
      'content': {'source': 'shamela.ws/book/1284', 'sha256': contentSha256},
      'sections': [
        for (final s in BackupSection.values)
          if (sections.contains(s)) s.name,
      ],
    };
    if (sections.contains(BackupSection.bookmarks)) {
      out['bookmark_folders'] = [
        for (final f in await _db.select(_db.bookmarkFolders).get())
          {'id': f.id, 'name': f.name, 'sort_order': f.sortOrder, 'created_at': iso(f.createdAt)},
      ];
      out['bookmarks'] = [
        for (final b in await _db.select(_db.bookmarks).get())
          {
            'hadith_uid': b.hadithUid,
            'hadith_number': numberByUid[b.hadithUid],
            'folder_id': b.folderId,
            'label': b.label,
            'created_at': iso(b.createdAt),
            'updated_at': iso(b.updatedAt),
          },
      ];
    }
    if (sections.contains(BackupSection.notes)) {
      out['notes'] = [
        for (final n in await _db.select(_db.notes).get())
          {
            'hadith_uid': n.hadithUid,
            'hadith_number': numberByUid[n.hadithUid],
            'body': n.body,
            'created_at': iso(n.createdAt),
            'updated_at': iso(n.updatedAt),
          },
      ];
    }
    if (sections.contains(BackupSection.progress)) {
      out['read_marks'] = [
        for (final r in await _db.select(_db.readMarks).get()) {'hadith_uid': r.hadithUid, 'read_at': iso(r.readAt)},
      ];
    }
    if (sections.contains(BackupSection.history)) {
      out['history'] = [
        for (final h in await _db.select(_db.historyEntries).get())
          {'hadith_uid': h.hadithUid, 'opened_at': iso(h.openedAt)},
      ];
      final p = await (_db.select(_db.readingPositions)..where((p) => p.id.equals(1))).getSingleOrNull();
      out['reading_position'] = p == null
          ? null
          : {
              'book_uid': p.bookUid,
              'chapter_uid': p.chapterUid,
              'hadith_uid': p.hadithUid,
              'anchor_offset': p.anchorOffset,
              'updated_at': iso(p.updatedAt),
            };
    }
    if (sections.contains(BackupSection.settings)) {
      out['settings'] = {for (final s in await _db.select(_db.settingEntries).get()) s.key: s.value};
    }
    return const JsonEncoder.withIndent('  ').convert(out);
  }

  /// Parses and validates [source] without changing any data.
  ///
  /// Hadith references must exist in [knownHadithUids]; book/chapter uids in
  /// the reading position must exist in [knownStructureUids].
  BackupData parse(String source, {required Set<String> knownHadithUids, required Set<String> knownStructureUids}) {
    final problems = <String>[];
    Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (e) {
      throw BackupFormatException(['not valid JSON: ${e.message}']);
    }
    if (decoded is! Map<String, dynamic>) {
      throw BackupFormatException(['the file is not a JSON object']);
    }
    final json = decoded;
    if (json['format'] != format) problems.add('format: expected "$format"');
    final version = json['schema_version'];
    if (version is! int) {
      problems.add('schema_version: missing');
    } else if (version > schemaVersion || version < 1) {
      problems.add('schema_version: $version is not supported (max $schemaVersion)');
    }
    if (problems.isNotEmpty) throw BackupFormatException(problems);

    final sections = <BackupSection>{};
    final folderIds = <int>{};

    bool isDate(Object? v) => v is String && DateTime.tryParse(v) != null;
    void checkList(String key, void Function(Map<String, dynamic> item, String path) check) {
      final list = json[key];
      if (list == null) return;
      if (list is! List) {
        problems.add('$key: must be a list');
        return;
      }
      for (var i = 0; i < list.length; i++) {
        final item = list[i];
        if (item is! Map<String, dynamic>) {
          problems.add('$key[$i]: must be an object');
        } else {
          check(item, '$key[$i]');
        }
      }
    }

    void checkUid(Map<String, dynamic> item, String path) {
      final uid = item['hadith_uid'];
      if (uid is! String) {
        problems.add('$path.hadith_uid: missing');
      } else if (!knownHadithUids.contains(uid)) {
        problems.add('$path.hadith_uid: "$uid" does not exist in this edition');
      }
    }

    checkList('bookmark_folders', (f, path) {
      if (f['id'] is! int) problems.add('$path.id: must be an integer');
      if (f['name'] is! String || (f['name'] as String).trim().isEmpty) {
        problems.add('$path.name: must be a non-empty string');
      }
      if (!isDate(f['created_at'])) problems.add('$path.created_at: invalid date');
      if (f['id'] is int && !folderIds.add(f['id'] as int)) {
        problems.add('$path.id: duplicate folder id');
      }
    });
    final seenBookmarks = <String>{};
    checkList('bookmarks', (b, path) {
      checkUid(b, path);
      final folder = b['folder_id'];
      if (folder != null && (folder is! int || !folderIds.contains(folder))) {
        problems.add('$path.folder_id: unknown folder');
      }
      if (b['label'] != null && b['label'] is! String) problems.add('$path.label: must be text');
      if (!isDate(b['created_at'])) problems.add('$path.created_at: invalid date');
      if (!isDate(b['updated_at'])) problems.add('$path.updated_at: invalid date');
      if (b['hadith_uid'] is String && !seenBookmarks.add(b['hadith_uid'] as String)) {
        problems.add('$path.hadith_uid: duplicate bookmark');
      }
    });
    final seenNotes = <String>{};
    checkList('notes', (n, path) {
      checkUid(n, path);
      if (n['body'] is! String) problems.add('$path.body: must be text');
      if (!isDate(n['created_at'])) problems.add('$path.created_at: invalid date');
      if (!isDate(n['updated_at'])) problems.add('$path.updated_at: invalid date');
      if (n['hadith_uid'] is String && !seenNotes.add(n['hadith_uid'] as String)) {
        problems.add('$path.hadith_uid: duplicate note');
      }
    });
    checkList('read_marks', (r, path) {
      checkUid(r, path);
      if (!isDate(r['read_at'])) problems.add('$path.read_at: invalid date');
    });
    checkList('history', (h, path) {
      checkUid(h, path);
      if (!isDate(h['opened_at'])) problems.add('$path.opened_at: invalid date');
    });
    final pos = json['reading_position'];
    if (pos != null) {
      if (pos is! Map<String, dynamic>) {
        problems.add('reading_position: must be an object');
      } else {
        if (pos['book_uid'] is! String || !knownStructureUids.contains(pos['book_uid'])) {
          problems.add('reading_position.book_uid: unknown book');
        }
        final c = pos['chapter_uid'];
        if (c != null && (c is! String || !knownStructureUids.contains(c))) {
          problems.add('reading_position.chapter_uid: unknown chapter');
        }
        final h = pos['hadith_uid'];
        if (h != null && (h is! String || !knownHadithUids.contains(h))) {
          problems.add('reading_position.hadith_uid: unknown hadith');
        }
        if (pos['anchor_offset'] is! num) problems.add('reading_position.anchor_offset: must be a number');
        if (!isDate(pos['updated_at'])) problems.add('reading_position.updated_at: invalid date');
      }
    }
    final settings = json['settings'];
    if (settings != null && (settings is! Map<String, dynamic> || settings.values.any((v) => v is! String))) {
      problems.add('settings: must be an object of text values');
    }
    if (problems.isNotEmpty) throw BackupFormatException(problems);

    if (json.containsKey('bookmarks') || json.containsKey('bookmark_folders')) {
      sections.add(BackupSection.bookmarks);
    }
    if (json.containsKey('notes')) sections.add(BackupSection.notes);
    if (json.containsKey('read_marks')) sections.add(BackupSection.progress);
    if (json.containsKey('history') || json.containsKey('reading_position')) {
      sections.add(BackupSection.history);
    }
    if (json.containsKey('settings')) sections.add(BackupSection.settings);
    if (sections.isEmpty) throw BackupFormatException(['the file contains no user data']);
    return BackupData._(sections, json);
  }

  /// Replaces the local data of every section present in [data]. Sections
  /// absent from the file are left untouched. Runs in one transaction.
  Future<RestoreSummary> restore(BackupData data) async {
    final j = data._json;
    DateTime d(Object? v) => DateTime.parse(v as String);
    List<Map<String, dynamic>> list(String k) => ((j[k] as List?) ?? const []).cast<Map<String, dynamic>>();
    return _db.transaction(() async {
      if (data.sections.contains(BackupSection.bookmarks)) {
        await _db.delete(_db.bookmarks).go();
        await _db.delete(_db.bookmarkFolders).go();
        await _db.batch((b) {
          b.insertAll(_db.bookmarkFolders, [
            for (final f in list('bookmark_folders'))
              BookmarkFoldersCompanion(
                id: Value(f['id'] as int),
                name: Value((f['name'] as String).trim()),
                sortOrder: Value((f['sort_order'] as int?) ?? 0),
                createdAt: Value(d(f['created_at'])),
              ),
          ]);
          b.insertAll(_db.bookmarks, [
            for (final m in list('bookmarks'))
              BookmarksCompanion(
                hadithUid: Value(m['hadith_uid'] as String),
                folderId: Value(m['folder_id'] as int?),
                label: Value(m['label'] as String?),
                createdAt: Value(d(m['created_at'])),
                updatedAt: Value(d(m['updated_at'])),
              ),
          ]);
        });
      }
      if (data.sections.contains(BackupSection.notes)) {
        await _db.delete(_db.notes).go();
        await _db.batch(
          (b) => b.insertAll(_db.notes, [
            for (final n in list('notes'))
              NotesCompanion(
                hadithUid: Value(n['hadith_uid'] as String),
                body: Value(n['body'] as String),
                createdAt: Value(d(n['created_at'])),
                updatedAt: Value(d(n['updated_at'])),
              ),
          ]),
        );
      }
      if (data.sections.contains(BackupSection.progress)) {
        await _db.delete(_db.readMarks).go();
        await _db.batch(
          (b) => b.insertAllOnConflictUpdate(_db.readMarks, [
            for (final r in list('read_marks'))
              ReadMarksCompanion(hadithUid: Value(r['hadith_uid'] as String), readAt: Value(d(r['read_at']))),
          ]),
        );
      }
      if (data.sections.contains(BackupSection.history)) {
        await _db.delete(_db.historyEntries).go();
        await _db.delete(_db.readingPositions).go();
        await _db.batch(
          (b) => b.insertAllOnConflictUpdate(_db.historyEntries, [
            for (final h in list('history'))
              HistoryEntriesCompanion(hadithUid: Value(h['hadith_uid'] as String), openedAt: Value(d(h['opened_at']))),
          ]),
        );
        final p = j['reading_position'] as Map<String, dynamic>?;
        if (p != null) {
          await _db
              .into(_db.readingPositions)
              .insert(
                ReadingPositionsCompanion(
                  id: const Value(1),
                  bookUid: Value(p['book_uid'] as String),
                  chapterUid: Value(p['chapter_uid'] as String?),
                  hadithUid: Value(p['hadith_uid'] as String?),
                  anchorOffset: Value((p['anchor_offset'] as num).toDouble()),
                  updatedAt: Value(d(p['updated_at'])),
                ),
              );
        }
      }
      if (data.sections.contains(BackupSection.settings)) {
        await _db.delete(_db.settingEntries).go();
        final s = (j['settings'] as Map<String, dynamic>?) ?? const {};
        await _db.batch(
          (b) => b.insertAll(_db.settingEntries, [
            for (final e in s.entries) SettingEntriesCompanion(key: Value(e.key), value: Value(e.value as String)),
          ]),
        );
      }
      return RestoreSummary(
        folders: data.count('bookmark_folders'),
        bookmarks: data.count('bookmarks'),
        notes: data.count('notes'),
        readMarks: data.count('read_marks'),
        history: data.count('history'),
        settings: (j['settings'] as Map?)?.length ?? 0,
      );
    });
  }
}
