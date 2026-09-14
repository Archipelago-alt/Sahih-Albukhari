import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/user/user_repository.dart';
import '../../shared/context_ext.dart';

final bookmarkFoldersProvider = StreamProvider<List<BookmarkFolder>>(
  (ref) => ref.watch(userRepositoryProvider).watchFolders(),
);

Future<String?> askFolderName(BuildContext context, {String? initial}) async {
  final controller = TextEditingController(text: initial ?? '');
  final l10n = context.l10n;
  final name = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(initial == null ? l10n.bookmarksNewFolder : l10n.bookmarksRenameFolder),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 80,
        decoration: InputDecoration(labelText: l10n.bookmarksFolderName),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: Text(l10n.save)),
      ],
    ),
  );
  controller.dispose();
  final t = name?.trim();
  return t == null || t.isEmpty ? null : t;
}

/// Edit the folder and short label of an existing bookmark.
Future<void> showBookmarkEditor(BuildContext context, WidgetRef ref, {required String hadithUid}) async {
  final repo = ref.read(userRepositoryProvider);
  final current = await repo.watchBookmark(hadithUid).first;
  if (current == null || !context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _BookmarkEditor(hadithUid: hadithUid, folderId: current.folderId, label: current.label),
  );
}

class _BookmarkEditor extends ConsumerStatefulWidget {
  const _BookmarkEditor({required this.hadithUid, this.folderId, this.label});

  final String hadithUid;
  final int? folderId;
  final String? label;

  @override
  ConsumerState<_BookmarkEditor> createState() => _BookmarkEditorState();
}

class _BookmarkEditorState extends ConsumerState<_BookmarkEditor> {
  late final _label = TextEditingController(text: widget.label ?? '');
  late int? _folder = widget.folderId;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final folders = ref.watch(bookmarkFoldersProvider).value ?? const [];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.bookmarkEdit, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _label,
                maxLength: 200,
                decoration: InputDecoration(labelText: l10n.bookmarkLabel, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      initialValue: folders.any((f) => f.id == _folder) ? _folder : null,
                      decoration: InputDecoration(labelText: l10n.bookmarkFolder, border: const OutlineInputBorder()),
                      items: [
                        DropdownMenuItem<int?>(value: null, child: Text(l10n.bookmarksNoFolder)),
                        for (final f in folders) DropdownMenuItem<int?>(value: f.id, child: Text(f.name)),
                      ],
                      onChanged: (v) => setState(() => _folder = v),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.bookmarksNewFolder,
                    icon: const Icon(Icons.create_new_folder_outlined),
                    onPressed: () async {
                      final name = await askFolderName(context);
                      if (name == null) return;
                      final id = await ref.read(userRepositoryProvider).createFolder(name);
                      setState(() => _folder = id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async {
                      await ref
                          .read(userRepositoryProvider)
                          .updateBookmark(widget.hadithUid, folderId: _folder, label: _label.text);
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
