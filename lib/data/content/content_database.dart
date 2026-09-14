import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// Read-only connection to the installed canonical content database.
///
/// The schema is produced by `tool/import/build_database.py`; this class
/// never creates or migrates it. Queries run on a background isolate so the
/// UI thread never blocks on SQLite.
class ContentDatabase extends GeneratedDatabase {
  ContentDatabase(super.executor);

  /// Opens [file] on a background isolate with writes disabled.
  factory ContentDatabase.open(File file) =>
      ContentDatabase(NativeDatabase.createInBackground(file, setup: (db) => db.execute('PRAGMA query_only = ON;')));

  /// Content schema version this app understands (`PRAGMA user_version`).
  /// Version 2: the editor's footnote tables were removed.
  static const int supportedSchemaVersion = 2;

  @override
  int get schemaVersion => supportedSchemaVersion;

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => const [];

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => throw StateError('The content database must be installed from the app assets.'),
    onUpgrade: (m, from, to) async => throw StateError('Unsupported content database version $from (expected $to).'),
  );
}
