import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../data/content/content_models.dart';
import '../../data/user/user_repository.dart';
import '../../shared/context_ext.dart';
import '../../shared/state_views.dart';
import '../reader/reader_target.dart';
import 'note_editor.dart';

class _Item {
  const _Item(this.note, this.hadith, this.book);
  final Note note;
  final Hadith hadith;
  final Book book;
}

final _noteItemsProvider = StreamProvider<List<_Item>>((ref) async* {
  final repo = ref.watch(contentRepositoryProvider);
  final books = {for (final b in await ref.watch(booksProvider.future)) b.id: b};
  await for (final notes in ref.watch(userRepositoryProvider).watchNotes()) {
    final hadiths = {
      for (final h in await repo.hadithsByUids([for (final n in notes) n.hadithUid])) h.uid: h,
    };
    yield [
      for (final n in notes)
        if (hadiths[n.hadithUid] case final h?) _Item(n, h, books[h.bookId]!),
    ];
  }
});

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notesTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.notesSearchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: AsyncBody(
              value: ref.watch(_noteItemsProvider),
              onRetry: () => ref.invalidate(_noteItemsProvider),
              data: (all) {
                final kept = UserRepository.filterNotes([for (final i in all) i.note], _query).toSet();
                final list = [
                  for (final i in all)
                    if (kept.contains(i.note)) i,
                ];
                if (list.isEmpty) {
                  return EmptyView(
                    icon: Icons.sticky_note_2_outlined,
                    title: l10n.notesEmpty,
                    message: _query.isEmpty ? l10n.notesEmptyHint : null,
                  );
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (context, i) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final item = list[i];
                    return ListTile(
                      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 8, 4, 8),
                      title: Text(item.note.body, maxLines: 3, overflow: TextOverflow.ellipsis),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${l10n.hadithNumberLabel(item.hadith.numberText)} · ${item.book.title}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      onTap: () =>
                          context.push(ReaderTarget(bookId: item.hadith.bookId, hadithId: item.hadith.id).location),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == 'edit') {
                            await showNoteEditor(context, ref, hadithUid: item.note.hadithUid, initial: item.note.body);
                          } else {
                            final ok = await context.confirm(
                              title: l10n.noteDeleteTitle,
                              message: l10n.noteDeleteConfirm,
                              confirmLabel: l10n.delete,
                              destructive: true,
                            );
                            if (ok) {
                              await ref.read(userRepositoryProvider).deleteNote(item.note.hadithUid);
                              if (context.mounted) context.showSnack(l10n.noteDeleted);
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                          PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
