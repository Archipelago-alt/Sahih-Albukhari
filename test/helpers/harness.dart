import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahih_albukhari/app/app.dart';
import 'package:sahih_albukhari/app/providers.dart';
import 'package:sahih_albukhari/app/router.dart';
import 'package:sahih_albukhari/data/content/content_database.dart';
import 'package:sahih_albukhari/data/user/user_database.dart';
import 'package:sahih_albukhari/features/settings/app_settings.dart';

const contentDbPath = 'assets/content/bukhari_taseel.db';

bool get contentAvailable => File(contentDbPath).existsSync();

/// The generated content database, opened read-only on the test isolate.
ContentDatabase openContent() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return ContentDatabase(NativeDatabase(File(contentDbPath), setup: (db) => db.execute('PRAGMA query_only = ON;')));
}

class TestDbs {
  TestDbs() : content = openContent(), user = UserDatabase.inMemory();

  final ContentDatabase content;
  final UserDatabase user;

  Future<void> close() async {
    await content.close();
    await user.close();
  }
}

Widget testApp(
  TestDbs dbs, {
  String location = '/',
  AppSettings settings = const AppSettings(),
  double textScale = 1,
}) => ProviderScope(
  overrides: [
    contentDatabaseProvider.overrideWithValue(dbs.content),
    userDatabaseProvider.overrideWithValue(dbs.user),
    initialSettingsProvider.overrideWithValue(settings),
    appVersionProvider.overrideWithValue('test'),
    initialLocationProvider.overrideWithValue(location),
  ],
  child: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(textScale), size: const Size(420, 900)),
    child: const SahihApp(),
  ),
);

/// Pumps real (not fake) time so that database futures complete.
Future<void> settle(WidgetTester tester, {int frames = 30}) async {
  for (var i = 0; i < frames; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Unmounts the app and closes the databases. Drift's shutdown waits on
/// timers of the test's fake clock, so the close must be driven by pumping
/// frames (awaiting it inside `runAsync` would deadlock).
Future<void> tearDownApp(WidgetTester tester, TestDbs dbs) async {
  await tester.pumpWidget(const SizedBox());
  var closed = false;
  unawaited(dbs.close().whenComplete(() => closed = true));
  for (var i = 0; i < 200 && !closed; i++) {
    // Let in-flight database work finish in real time, then run the fake
    // clock's timers; the close itself is never awaited inside runAsync.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    await tester.pump(const Duration(milliseconds: 20));
  }
  expect(closed, isTrue, reason: 'databases did not close');
}
