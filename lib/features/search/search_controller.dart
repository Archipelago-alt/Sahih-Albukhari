import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/content/content_models.dart';
import '../../data/content/search_repository.dart';
import '../settings/app_settings.dart';
import 'search_highlighter.dart';

class HadithResult {
  const HadithResult({required this.hadith, required this.book, required this.chapter, required this.snippet});

  final Hadith hadith;
  final Book book;
  final Chapter? chapter;
  final Snippet snippet;
}

class HeadingResult {
  const HeadingResult({required this.book, this.chapter});
  final Book book;
  final Chapter? chapter;
}

class SearchState {
  const SearchState({
    required this.request,
    this.total = 0,
    this.results = const [],
    this.headings = const [],
    this.byNumber = const [],
    this.loading = false,
    this.loadingMore = false,
    this.error = false,
    this.elapsed,
  });

  final SearchRequest request;
  final int total;
  final List<HadithResult> results;
  final List<HeadingResult> headings;
  final List<HadithResult> byNumber;
  final bool loading;
  final bool loadingMore;
  final bool error;
  final Duration? elapsed;

  bool get hasMore => results.length < total;

  SearchState copyWith({
    SearchRequest? request,
    int? total,
    List<HadithResult>? results,
    List<HeadingResult>? headings,
    List<HadithResult>? byNumber,
    bool? loading,
    bool? loadingMore,
    bool? error,
    Duration? elapsed,
  }) => SearchState(
    request: request ?? this.request,
    total: total ?? this.total,
    results: results ?? this.results,
    headings: headings ?? this.headings,
    byNumber: byNumber ?? this.byNumber,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    error: error ?? this.error,
    elapsed: elapsed ?? this.elapsed,
  );
}

/// Debounced, paginated search. Each new request cancels the previous one
/// (results of an outdated query are discarded).
class HadithSearchController extends Notifier<SearchState> {
  static const pageSize = 20;
  static const debounce = Duration(milliseconds: 350);

  Timer? _timer;
  int _generation = 0;

  @override
  SearchState build() {
    ref.onDispose(() => _timer?.cancel());
    final s = ref.read(settingsProvider);
    return SearchState(
      request: SearchRequest(query: '', broad: s.searchBroadDefault, wholeWords: s.searchWholeWordsDefault),
    );
  }

  void setRequest(SearchRequest request, {bool immediate = false}) {
    if (request == state.request && !immediate) return;
    state = state.copyWith(request: request);
    _timer?.cancel();
    if (request.isEmpty) {
      _generation++;
      state = SearchState(request: request);
      return;
    }
    _timer = Timer(immediate ? Duration.zero : debounce, _run);
  }

  Future<void> _run() async {
    final gen = ++_generation;
    final r = state.request;
    state = state.copyWith(
      loading: true,
      error: false,
      results: const [],
      headings: const [],
      byNumber: const [],
      total: 0,
    );
    final watch = Stopwatch()..start();
    try {
      final search = ref.read(searchRepositoryProvider);
      final content = ref.read(contentRepositoryProvider);
      final total = await search.countHadiths(r);
      final page = await _page(r, 0);
      final headingHits = await search.headings(r);
      final books = {for (final b in await ref.read(booksProvider.future)) b.id: b};
      final chapterRows = await content.chaptersByIds([
        for (final h in headingHits)
          if (h.kind == 'chapter') h.refId,
      ]);
      final chapterById = {for (final c in chapterRows) c.id: c};
      final headings = [
        for (final h in headingHits)
          HeadingResult(book: books[h.bookId]!, chapter: h.kind == 'chapter' ? chapterById[h.refId] : null),
      ];
      final number = r.hadithNumber;
      final byNumber = number == null
          ? const <HadithResult>[]
          : await _results(r, await content.hadithsByNumber(number));
      if (gen != _generation) return;
      state = state.copyWith(
        loading: false,
        total: total,
        results: page,
        headings: headings,
        byNumber: byNumber,
        elapsed: watch.elapsed,
      );
    } catch (_) {
      if (gen == _generation) state = state.copyWith(loading: false, error: true);
    }
  }

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) return;
    final gen = _generation;
    state = state.copyWith(loadingMore: true);
    try {
      final more = await _page(state.request, state.results.length);
      if (gen != _generation) return;
      state = state.copyWith(loadingMore: false, results: [...state.results, ...more]);
    } catch (_) {
      if (gen == _generation) state = state.copyWith(loadingMore: false, error: true);
    }
  }

  void retry() => setRequest(state.request, immediate: true);

  Future<List<HadithResult>> _page(SearchRequest r, int offset) async {
    final ids = await ref.read(searchRepositoryProvider).hadithIds(r, offset: offset, limit: pageSize);
    return _results(r, await ref.read(contentRepositoryProvider).hadithsByIds(ids));
  }

  Future<List<HadithResult>> _results(SearchRequest r, List<Hadith> hadiths) async {
    final books = {for (final b in await ref.read(booksProvider.future)) b.id: b};
    final chapters = {
      for (final c
          in await ref.read(contentRepositoryProvider).chaptersByIds(hadiths.map((h) => h.chapterId).toSet().toList()))
        c.id: c,
    };
    return [
      for (final h in hadiths)
        HadithResult(
          hadith: h,
          book: books[h.bookId]!,
          chapter: chapters[h.chapterId],
          snippet: SearchHighlighter.snippet(h.text, SearchHighlighter.find(h.text, r)),
        ),
    ];
  }
}

final searchControllerProvider = NotifierProvider.autoDispose<HadithSearchController, SearchState>(
  HadithSearchController.new,
);
