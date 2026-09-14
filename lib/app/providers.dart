import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/content/content_database.dart';
import '../data/content/content_models.dart';
import '../data/content/content_repository.dart';
import '../data/content/search_repository.dart';
import '../data/user/user_database.dart';
import '../data/user/user_repository.dart';
import '../features/backup/backup_service.dart';
import '../features/progress/progress_calculator.dart';
import '../features/settings/app_settings.dart';

// Overridden in main() once the databases are open.
final contentDatabaseProvider = Provider<ContentDatabase>((ref) => throw UnimplementedError('contentDatabaseProvider'));
final userDatabaseProvider = Provider<UserDatabase>((ref) => throw UnimplementedError('userDatabaseProvider'));
final initialSettingsProvider = Provider<AppSettings>((ref) => const AppSettings());
final appVersionProvider = Provider<String>((ref) => '');

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => ContentRepository(ref.watch(contentDatabaseProvider)),
);
final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepository(ref.watch(contentDatabaseProvider)),
);
final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepository(ref.watch(userDatabaseProvider)));
final backupServiceProvider = Provider<BackupService>((ref) => BackupService(ref.watch(userDatabaseProvider)));

// ------------------------------------------------------------------ content

final contentInfoProvider = FutureProvider<ContentInfo>((ref) => ref.watch(contentRepositoryProvider).info());

final booksProvider = FutureProvider<List<Book>>((ref) => ref.watch(contentRepositoryProvider).books());

final bookProvider = FutureProvider.family<Book, int>((ref, id) async {
  final books = await ref.watch(booksProvider.future);
  return books.firstWhere((b) => b.id == id);
});

final chaptersProvider = FutureProvider.family<List<Chapter>, int>(
  (ref, bookId) => ref.watch(contentRepositoryProvider).chaptersOfBook(bookId),
);

final hadithProvider = FutureProvider.family<Hadith?, int>(
  (ref, id) => ref.watch(contentRepositoryProvider).hadith(id),
);

final hadithByUidProvider = FutureProvider.family<Hadith?, String>((ref, uid) async {
  final list = await ref.watch(contentRepositoryProvider).hadithsByUids([uid]);
  return list.firstOrNull;
});

final bookOfHadithUidProvider = FutureProvider<Map<String, int>>(
  (ref) => ref.watch(contentRepositoryProvider).bookOfHadithUid(),
);

final hadithCountByBookProvider = FutureProvider<Map<int, int>>(
  (ref) => ref.watch(contentRepositoryProvider).hadithCountsByBook(),
);

// ---------------------------------------------------------------- user data

final bookmarkedUidsProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(userRepositoryProvider).watchBookmarkedUids(),
);
final notedUidsProvider = StreamProvider<Set<String>>((ref) => ref.watch(userRepositoryProvider).watchNotedUids());
final readUidsProvider = StreamProvider<Set<String>>((ref) => ref.watch(userRepositoryProvider).watchReadUids());
final historyProvider = StreamProvider<List<HistoryEntry>>((ref) => ref.watch(userRepositoryProvider).watchHistory());
final positionProvider = StreamProvider<ReadingPosition?>((ref) => ref.watch(userRepositoryProvider).watchPosition());
final searchHistoryProvider = StreamProvider<List<SearchHistoryEntry>>(
  (ref) => ref.watch(userRepositoryProvider).watchSearchHistory(),
);

final progressProvider = FutureProvider<ProgressSummary>((ref) async {
  final read = await ref.watch(readUidsProvider.future);
  final bookOf = await ref.watch(bookOfHadithUidProvider.future);
  final counts = await ref.watch(hadithCountByBookProvider.future);
  return ProgressCalculator.compute(readUids: read, bookOfUid: bookOf, hadithCountByBook: counts);
});
