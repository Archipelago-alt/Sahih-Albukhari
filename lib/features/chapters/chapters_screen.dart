import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/arabic/arabic_normalizer.dart';
import '../../data/content/content_models.dart';
import '../../shared/context_ext.dart';
import '../../shared/state_views.dart';
import '../reader/reader_target.dart';

class ChaptersScreen extends ConsumerStatefulWidget {
  const ChaptersScreen({super.key, required this.bookId});

  final int bookId;

  @override
  ConsumerState<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends ConsumerState<ChaptersScreen> {
  String _filter = '';
  final Set<int> _collapsed = {};
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final book = ref.watch(bookProvider(widget.bookId));
    final chapters = ref.watch(chaptersProvider(widget.bookId));
    return Scaffold(
      appBar: AppBar(
        title: Text(book.value?.title ?? '', textDirection: TextDirection.rtl),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => setState(() {
              if (v == 'expand') {
                _collapsed.clear();
              } else {
                _collapsed.addAll([
                  for (final c in chapters.value ?? const <Chapter>[])
                    if (c.depth == 1) c.id,
                ]);
              }
            }),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'expand', child: Text(l10n.chaptersExpandAll)),
              PopupMenuItem(value: 'collapse', child: Text(l10n.chaptersCollapseAll)),
            ],
          ),
        ],
      ),
      body: AsyncBody(
        value: chapters,
        onRetry: () => ref.invalidate(chaptersProvider(widget.bookId)),
        data: (all) {
          final visible = _visible(all);
          final hasChildren = {
            for (final c in all)
              if (c.parentId != null) c.parentId!,
          };
          return Scrollbar(
            controller: _scroll,
            interactive: true,
            thumbVisibility: true,
            child: CustomScrollView(
              controller: _scroll,
              slivers: [
                SliverToBoxAdapter(child: _BookHeader(bookId: widget.bookId)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: l10n.chaptersFilterHint,
                        prefixIcon: const Icon(Icons.filter_list),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (v) => setState(() => _filter = v),
                    ),
                  ),
                ),
                if (visible.isEmpty && _filter.isNotEmpty)
                  SliverToBoxAdapter(
                    child: EmptyView(icon: Icons.search_off, title: l10n.chaptersNoMatch),
                  ),
                SliverList.separated(
                  itemCount: visible.length,
                  separatorBuilder: (context, i) => const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, i) {
                    final c = visible[i];
                    return _ChapterTile(
                      chapter: c,
                      expandable: hasChildren.contains(c.id) && _filter.isEmpty,
                      expanded: !_collapsed.contains(c.id),
                      onToggle: () => setState(() {
                        _collapsed.contains(c.id) ? _collapsed.remove(c.id) : _collapsed.add(c.id);
                      }),
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Chapter> _visible(List<Chapter> all) {
    final named = [
      for (final c in all)
        if (!c.isImplicit) c,
    ];
    final q = ArabicNormalizer.normalize(_filter);
    if (q.isNotEmpty) {
      return [
        for (final c in named)
          if (ArabicNormalizer.normalize(c.heading ?? '').contains(q)) c,
      ];
    }
    final byId = {for (final c in all) c.id: c};
    bool hidden(Chapter c) {
      var p = c.parentId;
      while (p != null) {
        if (_collapsed.contains(p)) return true;
        p = byId[p]?.parentId;
      }
      return false;
    }

    return [
      for (final c in named)
        if (!hidden(c)) c,
    ];
  }
}

class _BookHeader extends ConsumerWidget {
  const _BookHeader({required this.bookId});

  final int bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final book = ref.watch(bookProvider(bookId)).value;
    if (book == null) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: ArabicText(
              book.heading,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFamily: 'Amiri',
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            [
              if (book.chapterCount > 0)
                context.l10n.bookChapters(book.chapterCount, context.number(book.chapterCount)),
              context.l10n.bookHadiths(book.hadithCount, context.number(book.hadithCount)),
            ].join(' · '),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Center(
            child: FilledButton.icon(
              icon: const Icon(Icons.chrome_reader_mode_outlined),
              label: Text(context.l10n.readWholeBook),
              onPressed: () => context.push(ReaderTarget(bookId: book.id).location),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterTile extends ConsumerWidget {
  const _ChapterTile({required this.chapter, required this.expandable, required this.expanded, required this.onToggle});

  final Chapter chapter;
  final bool expandable;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final indent = 16.0 + (chapter.depth - 1) * 20;
    return InkWell(
      onTap: () => context.push(ReaderTarget(bookId: chapter.bookId, chapterId: chapter.id).location),
      onLongPress: () => _menu(context, ref),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(indent, 12, 4, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ArabicText(
                    chapter.heading ?? '',
                    style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'Amiri', height: 1.7),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    chapter.hadithCount == 0
                        ? l10n.chapterNoHadiths
                        : l10n.bookHadiths(chapter.hadithCount, context.number(chapter.hadithCount)),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (expandable)
              IconButton(
                tooltip: expanded ? l10n.chaptersCollapseAll : l10n.chaptersExpandAll,
                icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: onToggle,
              ),
            IconButton(
              tooltip: context.l10n.readerMore,
              icon: const Icon(Icons.more_vert),
              onPressed: () => _menu(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _menu(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final choice = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.chrome_reader_mode_outlined),
              title: Text(l10n.chapterOpen),
              onTap: () => Navigator.pop(context, null),
            ),
            ListTile(
              leading: const Icon(Icons.done_all),
              title: Text(l10n.chapterMarkRead),
              onTap: () => Navigator.pop(context, true),
            ),
            ListTile(
              leading: const Icon(Icons.remove_done),
              title: Text(l10n.chapterMarkUnread),
              onTap: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ),
    );
    if (choice == null) {
      if (context.mounted) {
        unawaited(context.push(ReaderTarget(bookId: chapter.bookId, chapterId: chapter.id).location));
      }
      return;
    }
    final uids = await ref.read(contentRepositoryProvider).hadithUidsOfChapter(chapter.id);
    await ref.read(userRepositoryProvider).setRead(uids, read: choice);
  }
}
