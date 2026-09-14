import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../data/content/content_models.dart';
import '../../data/user/user_repository.dart';
import '../../shared/context_ext.dart';
import '../../shared/state_views.dart';
import '../reader/reader_target.dart';
import 'bookmark_editor.dart';

class _Item {
  const _Item(this.bookmark, this.hadith, this.book);
  final Bookmark bookmark;
  final Hadith hadith;
  final Book book;
}

final _bookmarkItemsProvider = StreamProvider<List<_Item>>((ref) async* {
  final repo = ref.watch(contentRepositoryProvider);
  final books = {for (final b in await ref.watch(booksProvider.future)) b.id: b};
  await for (final list in ref.watch(userRepositoryProvider).watchBookmarks()) {
    final hadiths = {
      for (final h in await repo.hadithsByUids([for (final b in list) b.hadithUid])) h.uid: h,
    };
    yield [
      for (final b in list)
        if (hadiths[b.hadithUid] case final h?) _Item(b, h, books[h.bookId]!),
    ];
  }
});

/// Folder filter: null = all, -1 = no folder, otherwise a folder id.
class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  int? _folder;
  BookmarkSort _sort = BookmarkSort.newest;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = ref.watch(_bookmarkItemsProvider);
    final folders = ref.watch(bookmarkFoldersProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookmarksTitle),
        actions: [
          PopupMenuButton<BookmarkSort>(
            tooltip: l10n.sortLabel,
            icon: const Icon(Icons.sort),
            initialValue: _sort,
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (context) => [
              PopupMenuItem(value: BookmarkSort.newest, child: Text(l10n.sortNewest)),
              PopupMenuItem(value: BookmarkSort.oldest, child: Text(l10n.sortOldest)),
              PopupMenuItem(value: BookmarkSort.canonical, child: Text(l10n.sortCanonical)),
            ],
          ),
          IconButton(
            tooltip: l10n.bookmarksNewFolder,
            icon: const Icon(Icons.create_new_folder_outlined),
            onPressed: () async {
              final name = await askFolderName(context);
              if (name != null) await ref.read(userRepositoryProvider).createFolder(name);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _chip(l10n.bookmarksAllFolders, null),
                _chip(l10n.bookmarksNoFolder, -1),
                for (final f in folders)
                  GestureDetector(onLongPress: () => _folderMenu(f.id, f.name), child: _chip(f.name, f.id)),
              ],
            ),
          ),
          Expanded(
            child: AsyncBody(
              value: items,
              onRetry: () => ref.invalidate(_bookmarkItemsProvider),
              data: (all) {
                final list = [
                  for (final i in all)
                    if (_folder == null ||
                        (_folder == -1 && i.bookmark.folderId == null) ||
                        i.bookmark.folderId == _folder)
                      i,
                ];
                switch (_sort) {
                  case BookmarkSort.newest:
                    list.sort((a, b) => b.bookmark.createdAt.compareTo(a.bookmark.createdAt));
                  case BookmarkSort.oldest:
                    list.sort((a, b) => a.bookmark.createdAt.compareTo(b.bookmark.createdAt));
                  case BookmarkSort.canonical:
                    list.sort((a, b) => a.hadith.sortOrder.compareTo(b.hadith.sortOrder));
                }
                if (list.isEmpty) {
                  return EmptyView(
                    icon: Icons.bookmark_border,
                    title: l10n.bookmarksEmpty,
                    message: l10n.bookmarksEmptyHint,
                  );
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (context, i) => const Divider(height: 1),
                  itemBuilder: (context, i) => _tile(list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, int? value) => Padding(
    padding: const EdgeInsetsDirectional.only(end: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: _folder == value,
      onSelected: (_) => setState(() => _folder = value),
    ),
  );

  Future<void> _folderMenu(int id, String name) async {
    final l10n = context.l10n;
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: Text(l10n.bookmarksRenameFolder),
              onTap: () => Navigator.pop(context, 'rename'),
            ),
            ListTile(
              leading: const Icon(Icons.folder_delete_outlined),
              title: Text(l10n.bookmarksDeleteFolder),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    final repo = ref.read(userRepositoryProvider);
    if (choice == 'rename') {
      final n = await askFolderName(context, initial: name);
      if (n != null) await repo.renameFolder(id, n);
    } else if (choice == 'delete') {
      final ok = await context.confirm(
        title: l10n.bookmarksDeleteFolder,
        message: l10n.bookmarksDeleteFolderConfirm(name),
        confirmLabel: l10n.delete,
        destructive: true,
      );
      if (ok) {
        await repo.deleteFolder(id);
        if (_folder == id) setState(() => _folder = null);
      }
    }
  }

  Widget _tile(_Item item) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final preview = item.hadith.text.length > 140 ? '${item.hadith.text.substring(0, 140)}…' : item.hadith.text;
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 8, 4, 8),
      title: Text(
        [
          l10n.hadithNumberLabel(item.hadith.numberText),
          if (item.bookmark.label != null) item.bookmark.label!,
        ].join(' — '),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ArabicText(item.book.heading, maxLines: 1, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          ArabicText(preview, maxLines: 2, style: const TextStyle(fontFamily: 'Amiri', fontSize: 16, height: 1.6)),
        ],
      ),
      onTap: () => context.push(ReaderTarget(bookId: item.hadith.bookId, hadithId: item.hadith.id).location),
      trailing: PopupMenuButton<String>(
        onSelected: (v) async {
          if (v == 'edit') {
            await showBookmarkEditor(context, ref, hadithUid: item.bookmark.hadithUid);
          } else {
            await ref.read(userRepositoryProvider).removeBookmark(item.bookmark.hadithUid);
            if (mounted) context.showSnack(l10n.bookmarkRemoved);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: 'edit', child: Text(l10n.bookmarkEdit)),
          PopupMenuItem(value: 'remove', child: Text(l10n.bookmarkRemove)),
        ],
      ),
    );
  }
}
