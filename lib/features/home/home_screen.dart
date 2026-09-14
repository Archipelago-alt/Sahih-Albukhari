import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../data/content/content_models.dart';
import '../../shared/context_ext.dart';
import '../../shared/state_views.dart';
import '../reader/reader_target.dart';

/// Resolved last reading position (uids from the user DB -> content rows).
class ResumeInfo {
  const ResumeInfo(this.target, this.book, this.chapter, this.hadith);

  final ReaderTarget target;
  final Book book;
  final Chapter? chapter;
  final Hadith? hadith;
}

final resumeProvider = FutureProvider<ResumeInfo?>((ref) async {
  final pos = await ref.watch(positionProvider.future);
  if (pos == null) return null;
  final repo = ref.watch(contentRepositoryProvider);
  final book = await repo.bookByUid(pos.bookUid);
  if (book == null) return null;
  final chapter = pos.chapterUid == null ? null : await repo.chapterByUid(pos.chapterUid!);
  final hadith = pos.hadithUid == null ? null : (await repo.hadithsByUids([pos.hadithUid!])).firstOrNull;
  return ResumeInfo(
    ReaderTarget(
      bookId: book.id,
      chapterId: hadith == null ? chapter?.id : null,
      hadithId: hadith?.id,
      anchorOffset: pos.anchorOffset,
    ),
    book,
    chapter,
    hadith,
  );
});

class _RecentItem {
  const _RecentItem(this.hadith, this.book);

  final Hadith hadith;
  final Book book;
}

final _recentProvider = FutureProvider<List<_RecentItem>>((ref) async {
  final history = await ref.watch(historyProvider.future);
  final hadiths = await ref.watch(contentRepositoryProvider).hadithsByUids([
    for (final h in history.take(6)) h.hadithUid,
  ]);
  final byUid = {for (final h in hadiths) h.uid: h};
  final books = {for (final b in await ref.watch(booksProvider.future)) b.id: b};
  return [
    for (final h in history.take(6))
      if (byUid[h.hadithUid] case final hadith?) _RecentItem(hadith, books[hadith.bookId]!),
  ];
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 8, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            header: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.appTitle,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontFamily: 'Amiri',
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  l10n.appSubtitle,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.homeSettings,
                          icon: const Icon(Icons.settings_outlined),
                          onPressed: () => context.push('/settings'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: _ContinueCard()),
                const SliverToBoxAdapter(child: _ProgressTile()),
                const SliverToBoxAdapter(child: _QuickActions()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 8),
                    child: Text(l10n.homeRecent, style: theme.textTheme.titleMedium),
                  ),
                ),
                const _RecentList(),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinueCard extends ConsumerWidget {
  const _ContinueCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final resume = ref.watch(resumeProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        color: theme.colorScheme.primaryContainer,
        child: resume.when(
          loading: () => const SizedBox(height: 120, child: LoadingView()),
          error: (e, st) => ErrorView(onRetry: () => ref.invalidate(resumeProvider)),
          data: (info) {
            final title = info == null ? l10n.homeStartReading : l10n.homeContinueReading;
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                if (info != null) {
                  unawaited(context.push(info.target.location));
                } else {
                  final books = await ref.read(booksProvider.future);
                  if (context.mounted && books.isNotEmpty) {
                    unawaited(context.push(ReaderTarget(bookId: books.first.id).location));
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (info == null)
                            Text(
                              l10n.homeStartReadingHint,
                              style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                            )
                          else ...[
                            ArabicText(
                              info.book.heading,
                              maxLines: 2,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontFamily: 'Amiri',
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            if (info.chapter?.heading case final heading?)
                              ArabicText(
                                heading,
                                maxLines: 2,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'Amiri',
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            if (info.hadith case final h?)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  l10n.hadithNumberLabel(h.numberText),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Directionality.of(context) == TextDirection.rtl ? Icons.arrow_back : Icons.arrow_forward,
                      color: theme.colorScheme.onPrimaryContainer,
                      semanticLabel: title,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProgressTile extends ConsumerWidget {
  const _ProgressTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = ref.watch(progressProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: progress.maybeWhen(
        orElse: () => const SizedBox.shrink(),
        data: (p) => Semantics(
          label: context.l10n.homeOverallProgress,
          value: context.l10n.homeProgressDetail(context.number(p.overall.read), context.number(p.overall.total)),
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(context.l10n.homeOverallProgress, style: theme.textTheme.titleSmall)),
                    Text(
                      p.overall.read == 0 ? '' : context.l10n.percentRead(context.number(p.overall.percent)),
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: p.overall.fraction,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 6),
                Text(
                  p.overall.read == 0
                      ? context.l10n.homeProgressNone
                      : context.l10n.homeProgressDetail(
                          context.number(p.overall.read),
                          context.number(p.overall.total),
                        ),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (Icons.menu_book_outlined, l10n.homeBrowseBooks, '/books'),
      (Icons.search, l10n.homeSearch, '/search'),
      (Icons.bookmark_border, l10n.homeBookmarks, '/bookmarks'),
      (Icons.sticky_note_2_outlined, l10n.homeNotes, '/notes'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth > 520 ? 4 : 2;
          final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final (icon, label, path) in items)
                SizedBox(
                  width: width,
                  child: FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(64),
                      alignment: AlignmentDirectional.centerStart,
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => context.push(path),
                    icon: Icon(icon),
                    label: Text(label),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RecentList extends ConsumerWidget {
  const _RecentList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(_recentProvider);
    return recent.when(
      loading: () => const SliverToBoxAdapter(child: LoadingView()),
      error: (e, st) => SliverToBoxAdapter(child: ErrorView(onRetry: () => ref.invalidate(_recentProvider))),
      data: (items) => items.isEmpty
          ? SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  context.l10n.homeRecentEmpty,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            )
          : SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (context, i) => const Divider(indent: 20, endIndent: 20, height: 1),
              itemBuilder: (context, i) {
                final item = items[i];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(context.l10n.hadithNumberLabel(item.hadith.numberText)),
                  subtitle: ArabicText(item.book.heading, maxLines: 1),
                  onTap: () => context.push(ReaderTarget(bookId: item.book.id, hadithId: item.hadith.id).location),
                );
              },
            ),
    );
  }
}
