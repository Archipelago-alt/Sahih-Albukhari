import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/arabic/arabic_normalizer.dart';
import '../../data/content/content_models.dart';
import '../../shared/context_ext.dart';
import '../../shared/state_views.dart';
import '../progress/progress_calculator.dart';

class BooksScreen extends ConsumerStatefulWidget {
  const BooksScreen({super.key});

  @override
  ConsumerState<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends ConsumerState<BooksScreen> {
  String _filter = '';
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  List<Book> _filtered(List<Book> books) {
    final q = ArabicNormalizer.normalize(_filter);
    if (q.isEmpty) return books;
    return [
      for (final b in books)
        if (ArabicNormalizer.normalize(b.heading).contains(q)) b,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final books = ref.watch(booksProvider);
    final progress = ref.watch(progressProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.booksTitle)),
      body: AsyncBody(
        value: books,
        onRetry: () => ref.invalidate(booksProvider),
        data: (all) {
          final list = _filtered(all);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.booksFilterHint,
                    prefixIcon: const Icon(Icons.filter_list),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _filter = v),
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? EmptyView(icon: Icons.search_off, title: l10n.booksNoMatch)
                    : Scrollbar(
                        controller: _scroll,
                        interactive: true,
                        thumbVisibility: true,
                        child: ListView.separated(
                          controller: _scroll,
                          itemCount: list.length,
                          separatorBuilder: (context, i) => const Divider(height: 1, indent: 72),
                          itemBuilder: (context, i) => _BookTile(book: list[i], progress: progress?.byBook[list[i].id]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({required this.book, required this.progress});

  final Book book;
  final ReadingProgress? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final meta = [
      if (book.chapterCount > 0) l10n.bookChapters(book.chapterCount, context.number(book.chapterCount)),
      l10n.bookHadiths(book.hadithCount, context.number(book.hadithCount)),
      if (progress != null && progress!.read > 0) l10n.percentRead(context.number(progress!.percent)),
    ].join(' · ');
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.secondaryContainer,
        foregroundColor: theme.colorScheme.onSecondaryContainer,
        child: Text(book.numberText ?? '', style: const TextStyle(fontSize: 14)),
      ),
      title: ArabicText(book.title, style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'Amiri', height: 1.6)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(meta),
          if (progress != null && progress!.read > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: LinearProgressIndicator(
                value: progress!.fraction,
                minHeight: 3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
      onTap: () => context.push('/books/${book.id}'),
    );
  }
}
