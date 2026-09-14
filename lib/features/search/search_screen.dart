import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../data/content/content_models.dart';
import '../../data/content/search_repository.dart';
import '../../shared/context_ext.dart';
import '../../shared/state_views.dart';
import '../reader/reader_target.dart';
import 'search_controller.dart';
import 'search_highlighter.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _text = TextEditingController();
  final _scroll = ScrollController();
  bool _showOptions = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 600) {
        ref.read(searchControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  HadithSearchController get _c => ref.read(searchControllerProvider.notifier);

  void _update(SearchRequest Function(SearchRequest r) f, {bool immediate = true}) =>
      _c.setRequest(f(ref.read(searchControllerProvider).request), immediate: immediate);

  void _open(ReaderTarget target) {
    final q = _text.text.trim();
    if (q.isNotEmpty) ref.read(userRepositoryProvider).addSearch(q);
    context.push(target.location);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(searchControllerProvider);
    final r = state.request;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _text,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(hintText: l10n.searchHint, border: InputBorder.none),
          onChanged: (v) => _update((r) => r.copyWith(query: v), immediate: false),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) ref.read(userRepositoryProvider).addSearch(v);
            _update((r) => r.copyWith(query: v));
          },
        ),
        actions: [
          if (_text.text.isNotEmpty)
            IconButton(
              tooltip: l10n.clear,
              icon: const Icon(Icons.close),
              onPressed: () {
                _text.clear();
                _update((r) => r.copyWith(query: ''));
                setState(() {});
              },
            ),
          IconButton(
            tooltip: l10n.searchOptions,
            icon: Icon(_showOptions ? Icons.tune : Icons.tune_outlined),
            onPressed: () => setState(() => _showOptions = !_showOptions),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: SegmentedButton<SearchMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: SearchMode.allWords, label: Text(l10n.searchModeAllWords)),
                ButtonSegment(value: SearchMode.phrase, label: Text(l10n.searchModePhrase)),
                ButtonSegment(value: SearchMode.exact, label: Text(l10n.searchModeExact)),
              ],
              selected: {r.mode},
              onSelectionChanged: (v) => _update((r) => r.copyWith(mode: v.first)),
            ),
          ),
          if (_showOptions) _Options(request: r, onChanged: (f) => _update(f)),
          Expanded(child: _body(state)),
        ],
      ),
    );
  }

  Widget _body(SearchState state) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (state.request.isEmpty) {
      return _RecentSearches(
        onPick: (q) {
          _text.text = q;
          _update((r) => r.copyWith(query: q));
          setState(() {});
        },
      );
    }
    if (state.loading) return const LoadingView();
    if (state.error) return ErrorView(onRetry: _c.retry);
    if (state.total == 0 && state.headings.isEmpty && state.byNumber.isEmpty) {
      return EmptyView(icon: Icons.search_off, title: l10n.searchNoResults, message: l10n.searchNoResultsHint);
    }
    Widget section(String title) => Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 4),
      child: Text(title, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
    );
    return ListView(
      controller: _scroll,
      children: [
        if (state.byNumber.isNotEmpty) ...[
          section(l10n.searchNumberTitle),
          for (final res in state.byNumber) _ResultTile(result: res, request: null, onOpen: _open),
        ],
        if (state.headings.isNotEmpty) ...[
          section(l10n.searchHeadingsTitle),
          for (final h in state.headings)
            ListTile(
              leading: Icon(h.chapter == null ? Icons.menu_book_outlined : Icons.segment),
              title: ArabicText(
                h.chapter?.heading ?? h.book.heading,
                style: const TextStyle(fontFamily: 'Amiri', fontSize: 17, height: 1.6),
              ),
              subtitle: h.chapter == null ? null : ArabicText(h.book.heading, maxLines: 1),
              onTap: () => h.chapter == null
                  ? context.push('/books/${h.book.id}')
                  : _open(ReaderTarget(bookId: h.book.id, chapterId: h.chapter!.id)),
            ),
        ],
        section('${l10n.searchHadithsTitle} — ${l10n.searchResultCount(state.total, context.number(state.total))}'),
        for (final res in state.results) _ResultTile(result: res, request: state.request, onOpen: _open),
        if (state.loadingMore) const LoadingView(),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _Options extends ConsumerWidget {
  const _Options({required this.request, required this.onChanged});

  final SearchRequest request;
  final void Function(SearchRequest Function(SearchRequest r) f) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final books = ref.watch(booksProvider).value ?? const [];
    final List<Chapter> chapters = request.bookId == null
        ? const []
        : [
            for (final c in ref.watch(chaptersProvider(request.bookId!)).value ?? const <Chapter>[])
              if (!c.isImplicit) c,
          ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: Column(
        children: [
          if (request.mode != SearchMode.exact) ...[
            SwitchListTile(
              dense: true,
              title: Text(l10n.searchWholeWords),
              value: request.wholeWords,
              onChanged: (v) => onChanged((r) => r.copyWith(wholeWords: v)),
            ),
            SwitchListTile(
              dense: true,
              title: Text(l10n.searchBroad),
              value: request.broad,
              onChanged: (v) => onChanged((r) => r.copyWith(broad: v)),
            ),
          ],
          DropdownButtonFormField<int?>(
            isExpanded: true,
            initialValue: request.bookId,
            decoration: InputDecoration(
              labelText: l10n.searchFilterBook,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem<int?>(value: null, child: Text(l10n.searchAnyBook)),
              for (final b in books)
                DropdownMenuItem<int?>(
                  value: b.id,
                  child: Text(b.heading, overflow: TextOverflow.ellipsis, textDirection: TextDirection.rtl),
                ),
            ],
            onChanged: (v) => onChanged((r) => r.copyWith(bookId: () => v, chapterId: () => null)),
          ),
          if (request.bookId != null) ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<int?>(
              key: ValueKey('chapters-${request.bookId}'),
              isExpanded: true,
              initialValue: request.chapterId,
              decoration: InputDecoration(
                labelText: l10n.searchFilterChapter,
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem<int?>(value: null, child: Text(l10n.searchAnyChapter)),
                for (final c in chapters)
                  DropdownMenuItem<int?>(
                    value: c.id,
                    child: Text(c.heading ?? '', overflow: TextOverflow.ellipsis, textDirection: TextDirection.rtl),
                  ),
              ],
              onChanged: (v) => onChanged((r) => r.copyWith(chapterId: () => v)),
            ),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.result, required this.request, required this.onOpen});

  final HadithResult result;
  final SearchRequest? request;
  final void Function(ReaderTarget t) onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = result.snippet;
    final base = const TextStyle(
      fontFamily: 'Amiri',
      fontFamilyFallback: ['NotoNaskhArabic'],
      fontSize: 17,
      height: 1.7,
    ).copyWith(color: theme.colorScheme.onSurface);
    final spans = <TextSpan>[];
    var pos = 0;
    if (s.clippedStart) spans.add(TextSpan(text: '… ', style: base));
    for (final MatchRange m in s.matches) {
      if (m.start > pos) spans.add(TextSpan(text: s.text.substring(pos, m.start), style: base));
      spans.add(
        TextSpan(
          text: s.text.substring(m.start, m.end),
          style: base.copyWith(backgroundColor: theme.colorScheme.tertiaryContainer, fontWeight: FontWeight.w700),
        ),
      );
      pos = m.end;
    }
    if (pos < s.text.length) spans.add(TextSpan(text: s.text.substring(pos), style: base));
    if (s.clippedEnd) spans.add(TextSpan(text: ' …', style: base));
    return InkWell(
      onTap: () => onOpen(ReaderTarget(bookId: result.book.id, hadithId: result.hadith.id, highlight: request)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.hadithNumberLabel(result.hadith.numberText),
              style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
            ),
            ArabicText(
              [result.book.title, ?result.chapter?.heading].join(' — '),
              maxLines: 2,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text.rich(TextSpan(children: spans), textDirection: TextDirection.rtl),
            const Divider(height: 20),
          ],
        ),
      ),
    );
  }
}

class _RecentSearches extends ConsumerWidget {
  const _RecentSearches({required this.onPick});

  final void Function(String q) onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final recent = ref.watch(searchHistoryProvider).value ?? const [];
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.searchStartHint,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        if (recent.isNotEmpty) ...[
          ListTile(
            title: Text(l10n.searchRecent, style: theme.textTheme.titleSmall),
            trailing: TextButton(
              onPressed: () => ref.read(userRepositoryProvider).clearSearchHistory(),
              child: Text(l10n.searchClearHistory),
            ),
          ),
          for (final e in recent)
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(e.query, textDirection: TextDirection.rtl),
              onTap: () => onPick(e.query),
              trailing: IconButton(
                tooltip: l10n.delete,
                icon: const Icon(Icons.close),
                onPressed: () => ref.read(userRepositoryProvider).removeSearch(e.query),
              ),
            ),
        ],
      ],
    );
  }
}
