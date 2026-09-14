// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_database.dart';

// ignore_for_file: type=lint
class $BookmarkFoldersTable extends BookmarkFolders with TableInfo<$BookmarkFoldersTable, BookmarkFolder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarkFoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 80),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, sortOrder, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmark_folders';
  @override
  VerificationContext validateIntegrity(Insertable<BookmarkFolder> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta, sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookmarkFolder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkFolder(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sortOrder: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BookmarkFoldersTable createAlias(String alias) {
    return $BookmarkFoldersTable(attachedDatabase, alias);
  }
}

class BookmarkFolder extends DataClass implements Insertable<BookmarkFolder> {
  final int id;
  final String name;
  final int sortOrder;
  final DateTime createdAt;
  const BookmarkFolder({required this.id, required this.name, required this.sortOrder, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookmarkFoldersCompanion toCompanion(bool nullToAbsent) {
    return BookmarkFoldersCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory BookmarkFolder.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkFolder(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BookmarkFolder copyWith({int? id, String? name, int? sortOrder, DateTime? createdAt}) => BookmarkFolder(
    id: id ?? this.id,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  BookmarkFolder copyWithCompanion(BookmarkFoldersCompanion data) {
    return BookmarkFolder(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkFolder(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkFolder &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class BookmarkFoldersCompanion extends UpdateCompanion<BookmarkFolder> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  const BookmarkFoldersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BookmarkFoldersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<BookmarkFolder> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BookmarkFoldersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
  }) {
    return BookmarkFoldersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkFoldersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks with TableInfo<$BookmarksTable, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _hadithUidMeta = const VerificationMeta('hadithUid');
  @override
  late final GeneratedColumn<String> hadithUid = GeneratedColumn<String>(
    'hadith_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta('folderId');
  @override
  late final GeneratedColumn<int> folderId = GeneratedColumn<int>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES bookmark_folders (id) ON DELETE SET NULL'),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 200),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, hadithUid, folderId, label, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(Insertable<Bookmark> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('hadith_uid')) {
      context.handle(_hadithUidMeta, hadithUid.isAcceptableOrUnknown(data['hadith_uid']!, _hadithUidMeta));
    } else if (isInserting) {
      context.missing(_hadithUidMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(_folderIdMeta, folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta));
    }
    if (data.containsKey('label')) {
      context.handle(_labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      hadithUid: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}hadith_uid'])!,
      folderId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}folder_id']),
      label: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}label']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  final int id;
  final String hadithUid;
  final int? folderId;
  final String? label;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Bookmark({
    required this.id,
    required this.hadithUid,
    this.folderId,
    this.label,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['hadith_uid'] = Variable<String>(hadithUid);
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<int>(folderId);
    }
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      hadithUid: Value(hadithUid),
      folderId: folderId == null && nullToAbsent ? const Value.absent() : Value(folderId),
      label: label == null && nullToAbsent ? const Value.absent() : Value(label),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Bookmark.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      id: serializer.fromJson<int>(json['id']),
      hadithUid: serializer.fromJson<String>(json['hadithUid']),
      folderId: serializer.fromJson<int?>(json['folderId']),
      label: serializer.fromJson<String?>(json['label']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'hadithUid': serializer.toJson<String>(hadithUid),
      'folderId': serializer.toJson<int?>(folderId),
      'label': serializer.toJson<String?>(label),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Bookmark copyWith({
    int? id,
    String? hadithUid,
    Value<int?> folderId = const Value.absent(),
    Value<String?> label = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Bookmark(
    id: id ?? this.id,
    hadithUid: hadithUid ?? this.hadithUid,
    folderId: folderId.present ? folderId.value : this.folderId,
    label: label.present ? label.value : this.label,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
      id: data.id.present ? data.id.value : this.id,
      hadithUid: data.hadithUid.present ? data.hadithUid.value : this.hadithUid,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      label: data.label.present ? data.label.value : this.label,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bookmark(')
          ..write('id: $id, ')
          ..write('hadithUid: $hadithUid, ')
          ..write('folderId: $folderId, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, hadithUid, folderId, label, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bookmark &&
          other.id == this.id &&
          other.hadithUid == this.hadithUid &&
          other.folderId == this.folderId &&
          other.label == this.label &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<int> id;
  final Value<String> hadithUid;
  final Value<int?> folderId;
  final Value<String?> label;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.hadithUid = const Value.absent(),
    this.folderId = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BookmarksCompanion.insert({
    this.id = const Value.absent(),
    required String hadithUid,
    this.folderId = const Value.absent(),
    this.label = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : hadithUid = Value(hadithUid),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Bookmark> custom({
    Expression<int>? id,
    Expression<String>? hadithUid,
    Expression<int>? folderId,
    Expression<String>? label,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hadithUid != null) 'hadith_uid': hadithUid,
      if (folderId != null) 'folder_id': folderId,
      if (label != null) 'label': label,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BookmarksCompanion copyWith({
    Value<int>? id,
    Value<String>? hadithUid,
    Value<int?>? folderId,
    Value<String?>? label,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return BookmarksCompanion(
      id: id ?? this.id,
      hadithUid: hadithUid ?? this.hadithUid,
      folderId: folderId ?? this.folderId,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (hadithUid.present) {
      map['hadith_uid'] = Variable<String>(hadithUid.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<int>(folderId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('hadithUid: $hadithUid, ')
          ..write('folderId: $folderId, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _hadithUidMeta = const VerificationMeta('hadithUid');
  @override
  late final GeneratedColumn<String> hadithUid = GeneratedColumn<String>(
    'hadith_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, hadithUid, body, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(Insertable<Note> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('hadith_uid')) {
      context.handle(_hadithUidMeta, hadithUid.isAcceptableOrUnknown(data['hadith_uid']!, _hadithUidMeta));
    } else if (isInserting) {
      context.missing(_hadithUidMeta);
    }
    if (data.containsKey('body')) {
      context.handle(_bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      hadithUid: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}hadith_uid'])!,
      body: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  final int id;
  final String hadithUid;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Note({
    required this.id,
    required this.hadithUid,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['hadith_uid'] = Variable<String>(hadithUid);
    map['body'] = Variable<String>(body);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      hadithUid: Value(hadithUid),
      body: Value(body),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Note.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<int>(json['id']),
      hadithUid: serializer.fromJson<String>(json['hadithUid']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'hadithUid': serializer.toJson<String>(hadithUid),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Note copyWith({int? id, String? hadithUid, String? body, DateTime? createdAt, DateTime? updatedAt}) => Note(
    id: id ?? this.id,
    hadithUid: hadithUid ?? this.hadithUid,
    body: body ?? this.body,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      hadithUid: data.hadithUid.present ? data.hadithUid.value : this.hadithUid,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('hadithUid: $hadithUid, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, hadithUid, body, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.hadithUid == this.hadithUid &&
          other.body == this.body &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<int> id;
  final Value<String> hadithUid;
  final Value<String> body;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.hadithUid = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    required String hadithUid,
    required String body,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : hadithUid = Value(hadithUid),
       body = Value(body),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Note> custom({
    Expression<int>? id,
    Expression<String>? hadithUid,
    Expression<String>? body,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hadithUid != null) 'hadith_uid': hadithUid,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  NotesCompanion copyWith({
    Value<int>? id,
    Value<String>? hadithUid,
    Value<String>? body,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      hadithUid: hadithUid ?? this.hadithUid,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (hadithUid.present) {
      map['hadith_uid'] = Variable<String>(hadithUid.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('hadithUid: $hadithUid, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ReadMarksTable extends ReadMarks with TableInfo<$ReadMarksTable, ReadMark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadMarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _hadithUidMeta = const VerificationMeta('hadithUid');
  @override
  late final GeneratedColumn<String> hadithUid = GeneratedColumn<String>(
    'hadith_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [hadithUid, readAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'read_marks';
  @override
  VerificationContext validateIntegrity(Insertable<ReadMark> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('hadith_uid')) {
      context.handle(_hadithUidMeta, hadithUid.isAcceptableOrUnknown(data['hadith_uid']!, _hadithUidMeta));
    } else if (isInserting) {
      context.missing(_hadithUidMeta);
    }
    if (data.containsKey('read_at')) {
      context.handle(_readAtMeta, readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta));
    } else if (isInserting) {
      context.missing(_readAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {hadithUid};
  @override
  ReadMark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadMark(
      hadithUid: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}hadith_uid'])!,
      readAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}read_at'])!,
    );
  }

  @override
  $ReadMarksTable createAlias(String alias) {
    return $ReadMarksTable(attachedDatabase, alias);
  }
}

class ReadMark extends DataClass implements Insertable<ReadMark> {
  final String hadithUid;
  final DateTime readAt;
  const ReadMark({required this.hadithUid, required this.readAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['hadith_uid'] = Variable<String>(hadithUid);
    map['read_at'] = Variable<DateTime>(readAt);
    return map;
  }

  ReadMarksCompanion toCompanion(bool nullToAbsent) {
    return ReadMarksCompanion(hadithUid: Value(hadithUid), readAt: Value(readAt));
  }

  factory ReadMark.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadMark(
      hadithUid: serializer.fromJson<String>(json['hadithUid']),
      readAt: serializer.fromJson<DateTime>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hadithUid': serializer.toJson<String>(hadithUid),
      'readAt': serializer.toJson<DateTime>(readAt),
    };
  }

  ReadMark copyWith({String? hadithUid, DateTime? readAt}) =>
      ReadMark(hadithUid: hadithUid ?? this.hadithUid, readAt: readAt ?? this.readAt);
  ReadMark copyWithCompanion(ReadMarksCompanion data) {
    return ReadMark(
      hadithUid: data.hadithUid.present ? data.hadithUid.value : this.hadithUid,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadMark(')
          ..write('hadithUid: $hadithUid, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(hadithUid, readAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ReadMark && other.hadithUid == this.hadithUid && other.readAt == this.readAt);
}

class ReadMarksCompanion extends UpdateCompanion<ReadMark> {
  final Value<String> hadithUid;
  final Value<DateTime> readAt;
  final Value<int> rowid;
  const ReadMarksCompanion({
    this.hadithUid = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadMarksCompanion.insert({required String hadithUid, required DateTime readAt, this.rowid = const Value.absent()})
    : hadithUid = Value(hadithUid),
      readAt = Value(readAt);
  static Insertable<ReadMark> custom({
    Expression<String>? hadithUid,
    Expression<DateTime>? readAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hadithUid != null) 'hadith_uid': hadithUid,
      if (readAt != null) 'read_at': readAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadMarksCompanion copyWith({Value<String>? hadithUid, Value<DateTime>? readAt, Value<int>? rowid}) {
    return ReadMarksCompanion(
      hadithUid: hadithUid ?? this.hadithUid,
      readAt: readAt ?? this.readAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hadithUid.present) {
      map['hadith_uid'] = Variable<String>(hadithUid.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadMarksCompanion(')
          ..write('hadithUid: $hadithUid, ')
          ..write('readAt: $readAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HistoryEntriesTable extends HistoryEntries with TableInfo<$HistoryEntriesTable, HistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _hadithUidMeta = const VerificationMeta('hadithUid');
  @override
  late final GeneratedColumn<String> hadithUid = GeneratedColumn<String>(
    'hadith_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta('openedAt');
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [hadithUid, openedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_entries';
  @override
  VerificationContext validateIntegrity(Insertable<HistoryEntry> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('hadith_uid')) {
      context.handle(_hadithUidMeta, hadithUid.isAcceptableOrUnknown(data['hadith_uid']!, _hadithUidMeta));
    } else if (isInserting) {
      context.missing(_hadithUidMeta);
    }
    if (data.containsKey('opened_at')) {
      context.handle(_openedAtMeta, openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta));
    } else if (isInserting) {
      context.missing(_openedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {hadithUid};
  @override
  HistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryEntry(
      hadithUid: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}hadith_uid'])!,
      openedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}opened_at'])!,
    );
  }

  @override
  $HistoryEntriesTable createAlias(String alias) {
    return $HistoryEntriesTable(attachedDatabase, alias);
  }
}

class HistoryEntry extends DataClass implements Insertable<HistoryEntry> {
  final String hadithUid;
  final DateTime openedAt;
  const HistoryEntry({required this.hadithUid, required this.openedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['hadith_uid'] = Variable<String>(hadithUid);
    map['opened_at'] = Variable<DateTime>(openedAt);
    return map;
  }

  HistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return HistoryEntriesCompanion(hadithUid: Value(hadithUid), openedAt: Value(openedAt));
  }

  factory HistoryEntry.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryEntry(
      hadithUid: serializer.fromJson<String>(json['hadithUid']),
      openedAt: serializer.fromJson<DateTime>(json['openedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hadithUid': serializer.toJson<String>(hadithUid),
      'openedAt': serializer.toJson<DateTime>(openedAt),
    };
  }

  HistoryEntry copyWith({String? hadithUid, DateTime? openedAt}) =>
      HistoryEntry(hadithUid: hadithUid ?? this.hadithUid, openedAt: openedAt ?? this.openedAt);
  HistoryEntry copyWithCompanion(HistoryEntriesCompanion data) {
    return HistoryEntry(
      hadithUid: data.hadithUid.present ? data.hadithUid.value : this.hadithUid,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEntry(')
          ..write('hadithUid: $hadithUid, ')
          ..write('openedAt: $openedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(hadithUid, openedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryEntry && other.hadithUid == this.hadithUid && other.openedAt == this.openedAt);
}

class HistoryEntriesCompanion extends UpdateCompanion<HistoryEntry> {
  final Value<String> hadithUid;
  final Value<DateTime> openedAt;
  final Value<int> rowid;
  const HistoryEntriesCompanion({
    this.hadithUid = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HistoryEntriesCompanion.insert({
    required String hadithUid,
    required DateTime openedAt,
    this.rowid = const Value.absent(),
  }) : hadithUid = Value(hadithUid),
       openedAt = Value(openedAt);
  static Insertable<HistoryEntry> custom({
    Expression<String>? hadithUid,
    Expression<DateTime>? openedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hadithUid != null) 'hadith_uid': hadithUid,
      if (openedAt != null) 'opened_at': openedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HistoryEntriesCompanion copyWith({Value<String>? hadithUid, Value<DateTime>? openedAt, Value<int>? rowid}) {
    return HistoryEntriesCompanion(
      hadithUid: hadithUid ?? this.hadithUid,
      openedAt: openedAt ?? this.openedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hadithUid.present) {
      map['hadith_uid'] = Variable<String>(hadithUid.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEntriesCompanion(')
          ..write('hadithUid: $hadithUid, ')
          ..write('openedAt: $openedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingPositionsTable extends ReadingPositions with TableInfo<$ReadingPositionsTable, ReadingPosition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingPositionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bookUidMeta = const VerificationMeta('bookUid');
  @override
  late final GeneratedColumn<String> bookUid = GeneratedColumn<String>(
    'book_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterUidMeta = const VerificationMeta('chapterUid');
  @override
  late final GeneratedColumn<String> chapterUid = GeneratedColumn<String>(
    'chapter_uid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hadithUidMeta = const VerificationMeta('hadithUid');
  @override
  late final GeneratedColumn<String> hadithUid = GeneratedColumn<String>(
    'hadith_uid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _anchorOffsetMeta = const VerificationMeta('anchorOffset');
  @override
  late final GeneratedColumn<double> anchorOffset = GeneratedColumn<double>(
    'anchor_offset',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, bookUid, chapterUid, hadithUid, anchorOffset, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_positions';
  @override
  VerificationContext validateIntegrity(Insertable<ReadingPosition> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_uid')) {
      context.handle(_bookUidMeta, bookUid.isAcceptableOrUnknown(data['book_uid']!, _bookUidMeta));
    } else if (isInserting) {
      context.missing(_bookUidMeta);
    }
    if (data.containsKey('chapter_uid')) {
      context.handle(_chapterUidMeta, chapterUid.isAcceptableOrUnknown(data['chapter_uid']!, _chapterUidMeta));
    }
    if (data.containsKey('hadith_uid')) {
      context.handle(_hadithUidMeta, hadithUid.isAcceptableOrUnknown(data['hadith_uid']!, _hadithUidMeta));
    }
    if (data.containsKey('anchor_offset')) {
      context.handle(_anchorOffsetMeta, anchorOffset.isAcceptableOrUnknown(data['anchor_offset']!, _anchorOffsetMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingPosition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingPosition(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookUid: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}book_uid'])!,
      chapterUid: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}chapter_uid']),
      hadithUid: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}hadith_uid']),
      anchorOffset: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}anchor_offset'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ReadingPositionsTable createAlias(String alias) {
    return $ReadingPositionsTable(attachedDatabase, alias);
  }
}

class ReadingPosition extends DataClass implements Insertable<ReadingPosition> {
  final int id;
  final String bookUid;
  final String? chapterUid;
  final String? hadithUid;

  /// Fraction of the anchor item scrolled past the top of the viewport
  /// (0 = item top at viewport top).
  final double anchorOffset;
  final DateTime updatedAt;
  const ReadingPosition({
    required this.id,
    required this.bookUid,
    this.chapterUid,
    this.hadithUid,
    required this.anchorOffset,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_uid'] = Variable<String>(bookUid);
    if (!nullToAbsent || chapterUid != null) {
      map['chapter_uid'] = Variable<String>(chapterUid);
    }
    if (!nullToAbsent || hadithUid != null) {
      map['hadith_uid'] = Variable<String>(hadithUid);
    }
    map['anchor_offset'] = Variable<double>(anchorOffset);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReadingPositionsCompanion toCompanion(bool nullToAbsent) {
    return ReadingPositionsCompanion(
      id: Value(id),
      bookUid: Value(bookUid),
      chapterUid: chapterUid == null && nullToAbsent ? const Value.absent() : Value(chapterUid),
      hadithUid: hadithUid == null && nullToAbsent ? const Value.absent() : Value(hadithUid),
      anchorOffset: Value(anchorOffset),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReadingPosition.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingPosition(
      id: serializer.fromJson<int>(json['id']),
      bookUid: serializer.fromJson<String>(json['bookUid']),
      chapterUid: serializer.fromJson<String?>(json['chapterUid']),
      hadithUid: serializer.fromJson<String?>(json['hadithUid']),
      anchorOffset: serializer.fromJson<double>(json['anchorOffset']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookUid': serializer.toJson<String>(bookUid),
      'chapterUid': serializer.toJson<String?>(chapterUid),
      'hadithUid': serializer.toJson<String?>(hadithUid),
      'anchorOffset': serializer.toJson<double>(anchorOffset),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReadingPosition copyWith({
    int? id,
    String? bookUid,
    Value<String?> chapterUid = const Value.absent(),
    Value<String?> hadithUid = const Value.absent(),
    double? anchorOffset,
    DateTime? updatedAt,
  }) => ReadingPosition(
    id: id ?? this.id,
    bookUid: bookUid ?? this.bookUid,
    chapterUid: chapterUid.present ? chapterUid.value : this.chapterUid,
    hadithUid: hadithUid.present ? hadithUid.value : this.hadithUid,
    anchorOffset: anchorOffset ?? this.anchorOffset,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReadingPosition copyWithCompanion(ReadingPositionsCompanion data) {
    return ReadingPosition(
      id: data.id.present ? data.id.value : this.id,
      bookUid: data.bookUid.present ? data.bookUid.value : this.bookUid,
      chapterUid: data.chapterUid.present ? data.chapterUid.value : this.chapterUid,
      hadithUid: data.hadithUid.present ? data.hadithUid.value : this.hadithUid,
      anchorOffset: data.anchorOffset.present ? data.anchorOffset.value : this.anchorOffset,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingPosition(')
          ..write('id: $id, ')
          ..write('bookUid: $bookUid, ')
          ..write('chapterUid: $chapterUid, ')
          ..write('hadithUid: $hadithUid, ')
          ..write('anchorOffset: $anchorOffset, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookUid, chapterUid, hadithUid, anchorOffset, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingPosition &&
          other.id == this.id &&
          other.bookUid == this.bookUid &&
          other.chapterUid == this.chapterUid &&
          other.hadithUid == this.hadithUid &&
          other.anchorOffset == this.anchorOffset &&
          other.updatedAt == this.updatedAt);
}

class ReadingPositionsCompanion extends UpdateCompanion<ReadingPosition> {
  final Value<int> id;
  final Value<String> bookUid;
  final Value<String?> chapterUid;
  final Value<String?> hadithUid;
  final Value<double> anchorOffset;
  final Value<DateTime> updatedAt;
  const ReadingPositionsCompanion({
    this.id = const Value.absent(),
    this.bookUid = const Value.absent(),
    this.chapterUid = const Value.absent(),
    this.hadithUid = const Value.absent(),
    this.anchorOffset = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ReadingPositionsCompanion.insert({
    this.id = const Value.absent(),
    required String bookUid,
    this.chapterUid = const Value.absent(),
    this.hadithUid = const Value.absent(),
    this.anchorOffset = const Value.absent(),
    required DateTime updatedAt,
  }) : bookUid = Value(bookUid),
       updatedAt = Value(updatedAt);
  static Insertable<ReadingPosition> custom({
    Expression<int>? id,
    Expression<String>? bookUid,
    Expression<String>? chapterUid,
    Expression<String>? hadithUid,
    Expression<double>? anchorOffset,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookUid != null) 'book_uid': bookUid,
      if (chapterUid != null) 'chapter_uid': chapterUid,
      if (hadithUid != null) 'hadith_uid': hadithUid,
      if (anchorOffset != null) 'anchor_offset': anchorOffset,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ReadingPositionsCompanion copyWith({
    Value<int>? id,
    Value<String>? bookUid,
    Value<String?>? chapterUid,
    Value<String?>? hadithUid,
    Value<double>? anchorOffset,
    Value<DateTime>? updatedAt,
  }) {
    return ReadingPositionsCompanion(
      id: id ?? this.id,
      bookUid: bookUid ?? this.bookUid,
      chapterUid: chapterUid ?? this.chapterUid,
      hadithUid: hadithUid ?? this.hadithUid,
      anchorOffset: anchorOffset ?? this.anchorOffset,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookUid.present) {
      map['book_uid'] = Variable<String>(bookUid.value);
    }
    if (chapterUid.present) {
      map['chapter_uid'] = Variable<String>(chapterUid.value);
    }
    if (hadithUid.present) {
      map['hadith_uid'] = Variable<String>(hadithUid.value);
    }
    if (anchorOffset.present) {
      map['anchor_offset'] = Variable<double>(anchorOffset.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingPositionsCompanion(')
          ..write('id: $id, ')
          ..write('bookUid: $bookUid, ')
          ..write('chapterUid: $chapterUid, ')
          ..write('hadithUid: $hadithUid, ')
          ..write('anchorOffset: $anchorOffset, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SearchHistoryEntriesTable extends SearchHistoryEntries
    with TableInfo<$SearchHistoryEntriesTable, SearchHistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SearchHistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _queryMeta = const VerificationMeta('query');
  @override
  late final GeneratedColumn<String> query = GeneratedColumn<String>(
    'query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchedAtMeta = const VerificationMeta('searchedAt');
  @override
  late final GeneratedColumn<DateTime> searchedAt = GeneratedColumn<DateTime>(
    'searched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [query, searchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'search_history_entries';
  @override
  VerificationContext validateIntegrity(Insertable<SearchHistoryEntry> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('query')) {
      context.handle(_queryMeta, query.isAcceptableOrUnknown(data['query']!, _queryMeta));
    } else if (isInserting) {
      context.missing(_queryMeta);
    }
    if (data.containsKey('searched_at')) {
      context.handle(_searchedAtMeta, searchedAt.isAcceptableOrUnknown(data['searched_at']!, _searchedAtMeta));
    } else if (isInserting) {
      context.missing(_searchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {query};
  @override
  SearchHistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SearchHistoryEntry(
      query: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}query'])!,
      searchedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}searched_at'])!,
    );
  }

  @override
  $SearchHistoryEntriesTable createAlias(String alias) {
    return $SearchHistoryEntriesTable(attachedDatabase, alias);
  }
}

class SearchHistoryEntry extends DataClass implements Insertable<SearchHistoryEntry> {
  final String query;
  final DateTime searchedAt;
  const SearchHistoryEntry({required this.query, required this.searchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['query'] = Variable<String>(query);
    map['searched_at'] = Variable<DateTime>(searchedAt);
    return map;
  }

  SearchHistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return SearchHistoryEntriesCompanion(query: Value(query), searchedAt: Value(searchedAt));
  }

  factory SearchHistoryEntry.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SearchHistoryEntry(
      query: serializer.fromJson<String>(json['query']),
      searchedAt: serializer.fromJson<DateTime>(json['searchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'query': serializer.toJson<String>(query),
      'searchedAt': serializer.toJson<DateTime>(searchedAt),
    };
  }

  SearchHistoryEntry copyWith({String? query, DateTime? searchedAt}) =>
      SearchHistoryEntry(query: query ?? this.query, searchedAt: searchedAt ?? this.searchedAt);
  SearchHistoryEntry copyWithCompanion(SearchHistoryEntriesCompanion data) {
    return SearchHistoryEntry(
      query: data.query.present ? data.query.value : this.query,
      searchedAt: data.searchedAt.present ? data.searchedAt.value : this.searchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryEntry(')
          ..write('query: $query, ')
          ..write('searchedAt: $searchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(query, searchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchHistoryEntry && other.query == this.query && other.searchedAt == this.searchedAt);
}

class SearchHistoryEntriesCompanion extends UpdateCompanion<SearchHistoryEntry> {
  final Value<String> query;
  final Value<DateTime> searchedAt;
  final Value<int> rowid;
  const SearchHistoryEntriesCompanion({
    this.query = const Value.absent(),
    this.searchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SearchHistoryEntriesCompanion.insert({
    required String query,
    required DateTime searchedAt,
    this.rowid = const Value.absent(),
  }) : query = Value(query),
       searchedAt = Value(searchedAt);
  static Insertable<SearchHistoryEntry> custom({
    Expression<String>? query,
    Expression<DateTime>? searchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (query != null) 'query': query,
      if (searchedAt != null) 'searched_at': searchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SearchHistoryEntriesCompanion copyWith({Value<String>? query, Value<DateTime>? searchedAt, Value<int>? rowid}) {
    return SearchHistoryEntriesCompanion(
      query: query ?? this.query,
      searchedAt: searchedAt ?? this.searchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (query.present) {
      map['query'] = Variable<String>(query.value);
    }
    if (searchedAt.present) {
      map['searched_at'] = Variable<DateTime>(searchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SearchHistoryEntriesCompanion(')
          ..write('query: $query, ')
          ..write('searchedAt: $searchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingEntriesTable extends SettingEntries with TableInfo<$SettingEntriesTable, SettingEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setting_entries';
  @override
  VerificationContext validateIntegrity(Insertable<SettingEntry> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingEntry(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingEntriesTable createAlias(String alias) {
    return $SettingEntriesTable(attachedDatabase, alias);
  }
}

class SettingEntry extends DataClass implements Insertable<SettingEntry> {
  final String key;
  final String value;
  const SettingEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingEntriesCompanion toCompanion(bool nullToAbsent) {
    return SettingEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory SettingEntry.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'key': serializer.toJson<String>(key), 'value': serializer.toJson<String>(value)};
  }

  SettingEntry copyWith({String? key, String? value}) => SettingEntry(key: key ?? this.key, value: value ?? this.value);
  SettingEntry copyWithCompanion(SettingEntriesCompanion data) {
    return SettingEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SettingEntry && other.key == this.key && other.value == this.value);
}

class SettingEntriesCompanion extends UpdateCompanion<SettingEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingEntriesCompanion.insert({required String key, required String value, this.rowid = const Value.absent()})
    : key = Value(key),
      value = Value(value);
  static Insertable<SettingEntry> custom({Expression<String>? key, Expression<String>? value, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingEntriesCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingEntriesCompanion(key: key ?? this.key, value: value ?? this.value, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$UserDatabase extends GeneratedDatabase {
  _$UserDatabase(QueryExecutor e) : super(e);
  $UserDatabaseManager get managers => $UserDatabaseManager(this);
  late final $BookmarkFoldersTable bookmarkFolders = $BookmarkFoldersTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $ReadMarksTable readMarks = $ReadMarksTable(this);
  late final $HistoryEntriesTable historyEntries = $HistoryEntriesTable(this);
  late final $ReadingPositionsTable readingPositions = $ReadingPositionsTable(this);
  late final $SearchHistoryEntriesTable searchHistoryEntries = $SearchHistoryEntriesTable(this);
  late final $SettingEntriesTable settingEntries = $SettingEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    bookmarkFolders,
    bookmarks,
    notes,
    readMarks,
    historyEntries,
    readingPositions,
    searchHistoryEntries,
    settingEntries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName('bookmark_folders', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('bookmarks', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$BookmarkFoldersTableCreateCompanionBuilder = BookmarkFoldersCompanion Function({
  Value<int> id,
  required String name,
  Value<int> sortOrder,
  required DateTime createdAt,
});
typedef $$BookmarkFoldersTableUpdateCompanionBuilder = BookmarkFoldersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
});

final class $$BookmarkFoldersTableReferences
    extends BaseReferences<_$UserDatabase, $BookmarkFoldersTable, BookmarkFolder> {
  $$BookmarkFoldersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BookmarksTable, List<Bookmark>> _bookmarksRefsTable(_$UserDatabase db) =>
      MultiTypedResultKey.fromTable(db.bookmarks, aliasName: 'bookmark_folders__id__bookmarks__folder_id');

  $$BookmarksTableProcessedTableManager get bookmarksRefs {
    final manager = $$BookmarksTableTableManager(
      $_db,
      $_db.bookmarks,
    ).filter((f) => f.folderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookmarksRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BookmarkFoldersTableFilterComposer extends Composer<_$UserDatabase, $BookmarkFoldersTable> {
  $$BookmarkFoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> bookmarksRefs(Expression<bool> Function($$BookmarksTableFilterComposer f) f) {
    final $$BookmarksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.folderId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$BookmarksTableFilterComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BookmarkFoldersTableOrderingComposer extends Composer<_$UserDatabase, $BookmarkFoldersTable> {
  $$BookmarkFoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BookmarkFoldersTableAnnotationComposer extends Composer<_$UserDatabase, $BookmarkFoldersTable> {
  $$BookmarkFoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder => $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> bookmarksRefs<T extends Object>(Expression<T> Function($$BookmarksTableAnnotationComposer a) f) {
    final $$BookmarksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.folderId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$BookmarksTableAnnotationComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BookmarkFoldersTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $BookmarkFoldersTable,
          BookmarkFolder,
          $$BookmarkFoldersTableFilterComposer,
          $$BookmarkFoldersTableOrderingComposer,
          $$BookmarkFoldersTableAnnotationComposer,
          $$BookmarkFoldersTableCreateCompanionBuilder,
          $$BookmarkFoldersTableUpdateCompanionBuilder,
          (BookmarkFolder, $$BookmarkFoldersTableReferences),
          BookmarkFolder,
          PrefetchHooks Function({bool bookmarksRefs})
        > {
  $$BookmarkFoldersTableTableManager(_$UserDatabase db, $BookmarkFoldersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$BookmarkFoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$BookmarkFoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$BookmarkFoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) => BookmarkFoldersCompanion(id: id, name: name, sortOrder: sortOrder, createdAt: createdAt),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<int> sortOrder = const Value.absent(),
            required DateTime createdAt,
          }) => BookmarkFoldersCompanion.insert(id: id, name: name, sortOrder: sortOrder, createdAt: createdAt),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookmarkFoldersTable, BookmarkFolder>(table),
                  $$BookmarkFoldersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookmarksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (bookmarksRefs) db.bookmarks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookmarksRefs)
                    await $_getPrefetchedData<BookmarkFolder, $BookmarkFoldersTable, Bookmark>(
                      currentTable: table,
                      referencedTable: $$BookmarkFoldersTableReferences._bookmarksRefsTable(db),
                      managerFromTypedResult: (p0) => $$BookmarkFoldersTableReferences(db, table, p0).bookmarksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.folderId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BookmarkFoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $BookmarkFoldersTable,
      BookmarkFolder,
      $$BookmarkFoldersTableFilterComposer,
      $$BookmarkFoldersTableOrderingComposer,
      $$BookmarkFoldersTableAnnotationComposer,
      $$BookmarkFoldersTableCreateCompanionBuilder,
      $$BookmarkFoldersTableUpdateCompanionBuilder,
      (BookmarkFolder, $$BookmarkFoldersTableReferences),
      BookmarkFolder,
      PrefetchHooks Function({bool bookmarksRefs})
    >;
typedef $$BookmarksTableCreateCompanionBuilder = BookmarksCompanion Function({
  Value<int> id,
  required String hadithUid,
  Value<int?> folderId,
  Value<String?> label,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$BookmarksTableUpdateCompanionBuilder = BookmarksCompanion Function({
  Value<int> id,
  Value<String> hadithUid,
  Value<int?> folderId,
  Value<String?> label,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$BookmarksTableReferences extends BaseReferences<_$UserDatabase, $BookmarksTable, Bookmark> {
  $$BookmarksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BookmarkFoldersTable _folderIdTable(_$UserDatabase db) =>
      db.bookmarkFolders.createAlias('bookmarks__folder_id__bookmark_folders__id');

  $$BookmarkFoldersTableProcessedTableManager? get folderId {
    final $_column = $_itemColumn<int>('folder_id');
    if ($_column == null) return null;
    final manager = $$BookmarkFoldersTableTableManager(
      $_db,
      $_db.bookmarkFolders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BookmarksTableFilterComposer extends Composer<_$UserDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hadithUid =>
      $composableBuilder(column: $table.hadithUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$BookmarkFoldersTableFilterComposer get folderId {
    final $$BookmarkFoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.bookmarkFolders,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$BookmarkFoldersTableFilterComposer(
            $db: $db,
            $table: $db.bookmarkFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableOrderingComposer extends Composer<_$UserDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hadithUid =>
      $composableBuilder(column: $table.hadithUid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$BookmarkFoldersTableOrderingComposer get folderId {
    final $$BookmarkFoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.bookmarkFolders,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$BookmarkFoldersTableOrderingComposer(
            $db: $db,
            $table: $db.bookmarkFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableAnnotationComposer extends Composer<_$UserDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hadithUid => $composableBuilder(column: $table.hadithUid, builder: (column) => column);

  GeneratedColumn<String> get label => $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BookmarkFoldersTableAnnotationComposer get folderId {
    final $$BookmarkFoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.bookmarkFolders,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$BookmarkFoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.bookmarkFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $BookmarksTable,
          Bookmark,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (Bookmark, $$BookmarksTableReferences),
          Bookmark,
          PrefetchHooks Function({bool folderId})
        > {
  $$BookmarksTableTableManager(_$UserDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> hadithUid = const Value.absent(),
                Value<int?> folderId = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BookmarksCompanion(
                id: id,
                hadithUid: hadithUid,
                folderId: folderId,
                label: label,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String hadithUid,
                Value<int?> folderId = const Value.absent(),
                Value<String?> label = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => BookmarksCompanion.insert(
                id: id,
                hadithUid: hadithUid,
                folderId: folderId,
                label: label,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable<$BookmarksTable, Bookmark>(table), $$BookmarksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({folderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (folderId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.folderId,
                        referencedTable: $$BookmarksTableReferences._folderIdTable(db),
                        referencedColumn: $$BookmarksTableReferences._folderIdTable(db).id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $BookmarksTable,
      Bookmark,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (Bookmark, $$BookmarksTableReferences),
      Bookmark,
      PrefetchHooks Function({bool folderId})
    >;
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  Value<int> id,
  required String hadithUid,
  required String body,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<int> id,
  Value<String> hadithUid,
  Value<String> body,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$NotesTableFilterComposer extends Composer<_$UserDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hadithUid =>
      $composableBuilder(column: $table.hadithUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$NotesTableOrderingComposer extends Composer<_$UserDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hadithUid =>
      $composableBuilder(column: $table.hadithUid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$NotesTableAnnotationComposer extends Composer<_$UserDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hadithUid => $composableBuilder(column: $table.hadithUid, builder: (column) => column);

  GeneratedColumn<String> get body => $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $NotesTable,
          Note,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (Note, BaseReferences<_$UserDatabase, $NotesTable, Note>),
          Note,
          PrefetchHooks Function()
        > {
  $$NotesTableTableManager(_$UserDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> hadithUid = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) => NotesCompanion(id: id, hadithUid: hadithUid, body: body, createdAt: createdAt, updatedAt: updatedAt),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String hadithUid,
                required String body,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => NotesCompanion.insert(
                id: id,
                hadithUid: hadithUid,
                body: body,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotesTable, Note>(table),
                  BaseReferences<_$UserDatabase, $NotesTable, Note>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $NotesTable,
      Note,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (Note, BaseReferences<_$UserDatabase, $NotesTable, Note>),
      Note,
      PrefetchHooks Function()
    >;
typedef $$ReadMarksTableCreateCompanionBuilder = ReadMarksCompanion Function({
  required String hadithUid,
  required DateTime readAt,
  Value<int> rowid,
});
typedef $$ReadMarksTableUpdateCompanionBuilder = ReadMarksCompanion Function({
  Value<String> hadithUid,
  Value<DateTime> readAt,
  Value<int> rowid,
});

class $$ReadMarksTableFilterComposer extends Composer<_$UserDatabase, $ReadMarksTable> {
  $$ReadMarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get hadithUid =>
      $composableBuilder(column: $table.hadithUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => ColumnFilters(column));
}

class $$ReadMarksTableOrderingComposer extends Composer<_$UserDatabase, $ReadMarksTable> {
  $$ReadMarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hadithUid =>
      $composableBuilder(column: $table.hadithUid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => ColumnOrderings(column));
}

class $$ReadMarksTableAnnotationComposer extends Composer<_$UserDatabase, $ReadMarksTable> {
  $$ReadMarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get hadithUid => $composableBuilder(column: $table.hadithUid, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt => $composableBuilder(column: $table.readAt, builder: (column) => column);
}

class $$ReadMarksTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $ReadMarksTable,
          ReadMark,
          $$ReadMarksTableFilterComposer,
          $$ReadMarksTableOrderingComposer,
          $$ReadMarksTableAnnotationComposer,
          $$ReadMarksTableCreateCompanionBuilder,
          $$ReadMarksTableUpdateCompanionBuilder,
          (ReadMark, BaseReferences<_$UserDatabase, $ReadMarksTable, ReadMark>),
          ReadMark,
          PrefetchHooks Function()
        > {
  $$ReadMarksTableTableManager(_$UserDatabase db, $ReadMarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ReadMarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ReadMarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ReadMarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> hadithUid = const Value.absent(),
            Value<DateTime> readAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => ReadMarksCompanion(hadithUid: hadithUid, readAt: readAt, rowid: rowid),
          createCompanionCallback: ({
            required String hadithUid,
            required DateTime readAt,
            Value<int> rowid = const Value.absent(),
          }) => ReadMarksCompanion.insert(hadithUid: hadithUid, readAt: readAt, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadMarksTable, ReadMark>(table),
                  BaseReferences<_$UserDatabase, $ReadMarksTable, ReadMark>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadMarksTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $ReadMarksTable,
      ReadMark,
      $$ReadMarksTableFilterComposer,
      $$ReadMarksTableOrderingComposer,
      $$ReadMarksTableAnnotationComposer,
      $$ReadMarksTableCreateCompanionBuilder,
      $$ReadMarksTableUpdateCompanionBuilder,
      (ReadMark, BaseReferences<_$UserDatabase, $ReadMarksTable, ReadMark>),
      ReadMark,
      PrefetchHooks Function()
    >;
typedef $$HistoryEntriesTableCreateCompanionBuilder = HistoryEntriesCompanion Function({
  required String hadithUid,
  required DateTime openedAt,
  Value<int> rowid,
});
typedef $$HistoryEntriesTableUpdateCompanionBuilder = HistoryEntriesCompanion Function({
  Value<String> hadithUid,
  Value<DateTime> openedAt,
  Value<int> rowid,
});

class $$HistoryEntriesTableFilterComposer extends Composer<_$UserDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get hadithUid =>
      $composableBuilder(column: $table.hadithUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => ColumnFilters(column));
}

class $$HistoryEntriesTableOrderingComposer extends Composer<_$UserDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hadithUid =>
      $composableBuilder(column: $table.hadithUid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => ColumnOrderings(column));
}

class $$HistoryEntriesTableAnnotationComposer extends Composer<_$UserDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get hadithUid => $composableBuilder(column: $table.hadithUid, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt => $composableBuilder(column: $table.openedAt, builder: (column) => column);
}

class $$HistoryEntriesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $HistoryEntriesTable,
          HistoryEntry,
          $$HistoryEntriesTableFilterComposer,
          $$HistoryEntriesTableOrderingComposer,
          $$HistoryEntriesTableAnnotationComposer,
          $$HistoryEntriesTableCreateCompanionBuilder,
          $$HistoryEntriesTableUpdateCompanionBuilder,
          (HistoryEntry, BaseReferences<_$UserDatabase, $HistoryEntriesTable, HistoryEntry>),
          HistoryEntry,
          PrefetchHooks Function()
        > {
  $$HistoryEntriesTableTableManager(_$UserDatabase db, $HistoryEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$HistoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$HistoryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$HistoryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> hadithUid = const Value.absent(),
            Value<DateTime> openedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => HistoryEntriesCompanion(hadithUid: hadithUid, openedAt: openedAt, rowid: rowid),
          createCompanionCallback: ({
            required String hadithUid,
            required DateTime openedAt,
            Value<int> rowid = const Value.absent(),
          }) => HistoryEntriesCompanion.insert(hadithUid: hadithUid, openedAt: openedAt, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HistoryEntriesTable, HistoryEntry>(table),
                  BaseReferences<_$UserDatabase, $HistoryEntriesTable, HistoryEntry>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HistoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $HistoryEntriesTable,
      HistoryEntry,
      $$HistoryEntriesTableFilterComposer,
      $$HistoryEntriesTableOrderingComposer,
      $$HistoryEntriesTableAnnotationComposer,
      $$HistoryEntriesTableCreateCompanionBuilder,
      $$HistoryEntriesTableUpdateCompanionBuilder,
      (HistoryEntry, BaseReferences<_$UserDatabase, $HistoryEntriesTable, HistoryEntry>),
      HistoryEntry,
      PrefetchHooks Function()
    >;
typedef $$ReadingPositionsTableCreateCompanionBuilder = ReadingPositionsCompanion Function({
  Value<int> id,
  required String bookUid,
  Value<String?> chapterUid,
  Value<String?> hadithUid,
  Value<double> anchorOffset,
  required DateTime updatedAt,
});
typedef $$ReadingPositionsTableUpdateCompanionBuilder = ReadingPositionsCompanion Function({
  Value<int> id,
  Value<String> bookUid,
  Value<String?> chapterUid,
  Value<String?> hadithUid,
  Value<double> anchorOffset,
  Value<DateTime> updatedAt,
});

class $$ReadingPositionsTableFilterComposer extends Composer<_$UserDatabase, $ReadingPositionsTable> {
  $$ReadingPositionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookUid =>
      $composableBuilder(column: $table.bookUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterUid =>
      $composableBuilder(column: $table.chapterUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hadithUid =>
      $composableBuilder(column: $table.hadithUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get anchorOffset =>
      $composableBuilder(column: $table.anchorOffset, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ReadingPositionsTableOrderingComposer extends Composer<_$UserDatabase, $ReadingPositionsTable> {
  $$ReadingPositionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookUid =>
      $composableBuilder(column: $table.bookUid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterUid =>
      $composableBuilder(column: $table.chapterUid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hadithUid =>
      $composableBuilder(column: $table.hadithUid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get anchorOffset =>
      $composableBuilder(column: $table.anchorOffset, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ReadingPositionsTableAnnotationComposer extends Composer<_$UserDatabase, $ReadingPositionsTable> {
  $$ReadingPositionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookUid => $composableBuilder(column: $table.bookUid, builder: (column) => column);

  GeneratedColumn<String> get chapterUid => $composableBuilder(column: $table.chapterUid, builder: (column) => column);

  GeneratedColumn<String> get hadithUid => $composableBuilder(column: $table.hadithUid, builder: (column) => column);

  GeneratedColumn<double> get anchorOffset =>
      $composableBuilder(column: $table.anchorOffset, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ReadingPositionsTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $ReadingPositionsTable,
          ReadingPosition,
          $$ReadingPositionsTableFilterComposer,
          $$ReadingPositionsTableOrderingComposer,
          $$ReadingPositionsTableAnnotationComposer,
          $$ReadingPositionsTableCreateCompanionBuilder,
          $$ReadingPositionsTableUpdateCompanionBuilder,
          (ReadingPosition, BaseReferences<_$UserDatabase, $ReadingPositionsTable, ReadingPosition>),
          ReadingPosition,
          PrefetchHooks Function()
        > {
  $$ReadingPositionsTableTableManager(_$UserDatabase db, $ReadingPositionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ReadingPositionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ReadingPositionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ReadingPositionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> bookUid = const Value.absent(),
                Value<String?> chapterUid = const Value.absent(),
                Value<String?> hadithUid = const Value.absent(),
                Value<double> anchorOffset = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ReadingPositionsCompanion(
                id: id,
                bookUid: bookUid,
                chapterUid: chapterUid,
                hadithUid: hadithUid,
                anchorOffset: anchorOffset,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String bookUid,
                Value<String?> chapterUid = const Value.absent(),
                Value<String?> hadithUid = const Value.absent(),
                Value<double> anchorOffset = const Value.absent(),
                required DateTime updatedAt,
              }) => ReadingPositionsCompanion.insert(
                id: id,
                bookUid: bookUid,
                chapterUid: chapterUid,
                hadithUid: hadithUid,
                anchorOffset: anchorOffset,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadingPositionsTable, ReadingPosition>(table),
                  BaseReferences<_$UserDatabase, $ReadingPositionsTable, ReadingPosition>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingPositionsTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $ReadingPositionsTable,
      ReadingPosition,
      $$ReadingPositionsTableFilterComposer,
      $$ReadingPositionsTableOrderingComposer,
      $$ReadingPositionsTableAnnotationComposer,
      $$ReadingPositionsTableCreateCompanionBuilder,
      $$ReadingPositionsTableUpdateCompanionBuilder,
      (ReadingPosition, BaseReferences<_$UserDatabase, $ReadingPositionsTable, ReadingPosition>),
      ReadingPosition,
      PrefetchHooks Function()
    >;
typedef $$SearchHistoryEntriesTableCreateCompanionBuilder = SearchHistoryEntriesCompanion Function({
  required String query,
  required DateTime searchedAt,
  Value<int> rowid,
});
typedef $$SearchHistoryEntriesTableUpdateCompanionBuilder = SearchHistoryEntriesCompanion Function({
  Value<String> query,
  Value<DateTime> searchedAt,
  Value<int> rowid,
});

class $$SearchHistoryEntriesTableFilterComposer extends Composer<_$UserDatabase, $SearchHistoryEntriesTable> {
  $$SearchHistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get searchedAt =>
      $composableBuilder(column: $table.searchedAt, builder: (column) => ColumnFilters(column));
}

class $$SearchHistoryEntriesTableOrderingComposer extends Composer<_$UserDatabase, $SearchHistoryEntriesTable> {
  $$SearchHistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get query =>
      $composableBuilder(column: $table.query, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get searchedAt =>
      $composableBuilder(column: $table.searchedAt, builder: (column) => ColumnOrderings(column));
}

class $$SearchHistoryEntriesTableAnnotationComposer extends Composer<_$UserDatabase, $SearchHistoryEntriesTable> {
  $$SearchHistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get query => $composableBuilder(column: $table.query, builder: (column) => column);

  GeneratedColumn<DateTime> get searchedAt =>
      $composableBuilder(column: $table.searchedAt, builder: (column) => column);
}

class $$SearchHistoryEntriesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $SearchHistoryEntriesTable,
          SearchHistoryEntry,
          $$SearchHistoryEntriesTableFilterComposer,
          $$SearchHistoryEntriesTableOrderingComposer,
          $$SearchHistoryEntriesTableAnnotationComposer,
          $$SearchHistoryEntriesTableCreateCompanionBuilder,
          $$SearchHistoryEntriesTableUpdateCompanionBuilder,
          (SearchHistoryEntry, BaseReferences<_$UserDatabase, $SearchHistoryEntriesTable, SearchHistoryEntry>),
          SearchHistoryEntry,
          PrefetchHooks Function()
        > {
  $$SearchHistoryEntriesTableTableManager(_$UserDatabase db, $SearchHistoryEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SearchHistoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SearchHistoryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SearchHistoryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> query = const Value.absent(),
            Value<DateTime> searchedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SearchHistoryEntriesCompanion(query: query, searchedAt: searchedAt, rowid: rowid),
          createCompanionCallback: ({
            required String query,
            required DateTime searchedAt,
            Value<int> rowid = const Value.absent(),
          }) => SearchHistoryEntriesCompanion.insert(query: query, searchedAt: searchedAt, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SearchHistoryEntriesTable, SearchHistoryEntry>(table),
                  BaseReferences<_$UserDatabase, $SearchHistoryEntriesTable, SearchHistoryEntry>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SearchHistoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $SearchHistoryEntriesTable,
      SearchHistoryEntry,
      $$SearchHistoryEntriesTableFilterComposer,
      $$SearchHistoryEntriesTableOrderingComposer,
      $$SearchHistoryEntriesTableAnnotationComposer,
      $$SearchHistoryEntriesTableCreateCompanionBuilder,
      $$SearchHistoryEntriesTableUpdateCompanionBuilder,
      (SearchHistoryEntry, BaseReferences<_$UserDatabase, $SearchHistoryEntriesTable, SearchHistoryEntry>),
      SearchHistoryEntry,
      PrefetchHooks Function()
    >;
typedef $$SettingEntriesTableCreateCompanionBuilder = SettingEntriesCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingEntriesTableUpdateCompanionBuilder = SettingEntriesCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingEntriesTableFilterComposer extends Composer<_$UserDatabase, $SettingEntriesTable> {
  $$SettingEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SettingEntriesTableOrderingComposer extends Composer<_$UserDatabase, $SettingEntriesTable> {
  $$SettingEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SettingEntriesTableAnnotationComposer extends Composer<_$UserDatabase, $SettingEntriesTable> {
  $$SettingEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key => $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value => $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingEntriesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $SettingEntriesTable,
          SettingEntry,
          $$SettingEntriesTableFilterComposer,
          $$SettingEntriesTableOrderingComposer,
          $$SettingEntriesTableAnnotationComposer,
          $$SettingEntriesTableCreateCompanionBuilder,
          $$SettingEntriesTableUpdateCompanionBuilder,
          (SettingEntry, BaseReferences<_$UserDatabase, $SettingEntriesTable, SettingEntry>),
          SettingEntry,
          PrefetchHooks Function()
        > {
  $$SettingEntriesTableTableManager(_$UserDatabase db, $SettingEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SettingEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SettingEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SettingEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingEntriesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingEntriesCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingEntriesTable, SettingEntry>(table),
                  BaseReferences<_$UserDatabase, $SettingEntriesTable, SettingEntry>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $SettingEntriesTable,
      SettingEntry,
      $$SettingEntriesTableFilterComposer,
      $$SettingEntriesTableOrderingComposer,
      $$SettingEntriesTableAnnotationComposer,
      $$SettingEntriesTableCreateCompanionBuilder,
      $$SettingEntriesTableUpdateCompanionBuilder,
      (SettingEntry, BaseReferences<_$UserDatabase, $SettingEntriesTable, SettingEntry>),
      SettingEntry,
      PrefetchHooks Function()
    >;

class $UserDatabaseManager {
  final _$UserDatabase _db;
  $UserDatabaseManager(this._db);
  $$BookmarkFoldersTableTableManager get bookmarkFolders =>
      $$BookmarkFoldersTableTableManager(_db, _db.bookmarkFolders);
  $$BookmarksTableTableManager get bookmarks => $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$NotesTableTableManager get notes => $$NotesTableTableManager(_db, _db.notes);
  $$ReadMarksTableTableManager get readMarks => $$ReadMarksTableTableManager(_db, _db.readMarks);
  $$HistoryEntriesTableTableManager get historyEntries => $$HistoryEntriesTableTableManager(_db, _db.historyEntries);
  $$ReadingPositionsTableTableManager get readingPositions =>
      $$ReadingPositionsTableTableManager(_db, _db.readingPositions);
  $$SearchHistoryEntriesTableTableManager get searchHistoryEntries =>
      $$SearchHistoryEntriesTableTableManager(_db, _db.searchHistoryEntries);
  $$SettingEntriesTableTableManager get settingEntries => $$SettingEntriesTableTableManager(_db, _db.settingEntries);
}
