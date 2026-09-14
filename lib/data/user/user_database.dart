import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'user_database.g.dart';

/// Private, local-only user data. Hadiths are referenced by their stable
/// `uid` from the content database (e.g. "h16"), never by row id, so user
/// data survives content updates.
class BookmarkFolders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get hadithUid => text().unique()();
  IntColumn get folderId => integer().nullable().references(BookmarkFolders, #id, onDelete: KeyAction.setNull)();
  TextColumn get label => text().nullable().withLength(max: 200)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get hadithUid => text().unique()();
  TextColumn get body => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class ReadMarks extends Table {
  TextColumn get hadithUid => text()();
  DateTimeColumn get readAt => dateTime()();

  @override
  Set<Column> get primaryKey => {hadithUid};
}

class HistoryEntries extends Table {
  TextColumn get hadithUid => text()();
  DateTimeColumn get openedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {hadithUid};
}

/// The single last reading position (row id 1).
class ReadingPositions extends Table {
  IntColumn get id => integer()();
  TextColumn get bookUid => text()();
  TextColumn get chapterUid => text().nullable()();
  TextColumn get hadithUid => text().nullable()();

  /// Fraction of the anchor item scrolled past the top of the viewport
  /// (0 = item top at viewport top).
  RealColumn get anchorOffset => real().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class SearchHistoryEntries extends Table {
  TextColumn get query => text()();
  DateTimeColumn get searchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {query};
}

class SettingEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    BookmarkFolders,
    Bookmarks,
    Notes,
    ReadMarks,
    HistoryEntries,
    ReadingPositions,
    SearchHistoryEntries,
    SettingEntries,
  ],
)
class UserDatabase extends _$UserDatabase {
  UserDatabase(super.executor);

  factory UserDatabase.open(File file) => UserDatabase(NativeDatabase.createInBackground(file));

  factory UserDatabase.inMemory() => UserDatabase(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
