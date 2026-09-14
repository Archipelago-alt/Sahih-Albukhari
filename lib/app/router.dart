import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/bookmarks/bookmarks_screen.dart';
import '../features/books/books_screen.dart';
import '../features/chapters/chapters_screen.dart';
import '../features/home/home_screen.dart';
import '../features/notes/notes_screen.dart';
import '../features/reader/reader_screen.dart';
import '../features/reader/reader_target.dart';
import '../features/search/search_screen.dart';
import '../features/settings/about_screen.dart';
import '../features/settings/settings_screen.dart';

/// Overridable in tests to start on a specific screen.
final initialLocationProvider = Provider<String>((ref) => '/');

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: ref.watch(initialLocationProvider),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'books',
            builder: (context, state) => const BooksScreen(),
            routes: [
              GoRoute(
                path: ':bookId',
                builder: (context, state) => ChaptersScreen(bookId: int.parse(state.pathParameters['bookId']!)),
              ),
            ],
          ),
          GoRoute(
            path: 'read/:bookId',
            builder: (context, state) => ReaderScreen(
              target: ReaderTarget.fromUri(int.parse(state.pathParameters['bookId']!), state.uri.queryParameters),
            ),
          ),
          GoRoute(path: 'search', builder: (context, state) => const SearchScreen()),
          GoRoute(path: 'bookmarks', builder: (context, state) => const BookmarksScreen()),
          GoRoute(path: 'notes', builder: (context, state) => const NotesScreen()),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [GoRoute(path: 'about', builder: (context, state) => const AboutScreen())],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
