import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../shared/context_ext.dart';

/// Edits the private note of one hadith. The hadith text is never touched.
Future<void> showNoteEditor(BuildContext context, WidgetRef ref, {required String hadithUid, String? initial}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _NoteEditor(hadithUid: hadithUid, initial: initial),
    );

class _NoteEditor extends ConsumerStatefulWidget {
  const _NoteEditor({required this.hadithUid, this.initial});

  final String hadithUid;
  final String? initial;

  @override
  ConsumerState<_NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends ConsumerState<_NoteEditor> {
  late final _controller = TextEditingController(text: widget.initial ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    if (_controller.text.trim().isEmpty) {
      context.showSnack(l10n.noteEmptyError);
      return;
    }
    await ref.read(userRepositoryProvider).saveNote(widget.hadithUid, _controller.text);
    if (!mounted) return;
    Navigator.pop(context);
    context.showSnack(l10n.noteSaved);
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final ok = await context.confirm(
      title: l10n.noteDeleteTitle,
      message: l10n.noteDeleteConfirm,
      confirmLabel: l10n.delete,
      destructive: true,
    );
    if (!ok || !mounted) return;
    await ref.read(userRepositoryProvider).deleteNote(widget.hadithUid);
    if (!mounted) return;
    Navigator.pop(context);
    context.showSnack(l10n.noteDeleted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.noteEditorTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.lock_outline, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.notePrivateBadge,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                autofocus: true,
                minLines: 4,
                maxLines: 12,
                decoration: InputDecoration(hintText: l10n.noteHint, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (widget.initial != null)
                    TextButton.icon(
                      onPressed: _delete,
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.delete),
                      style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                    ),
                  const Spacer(),
                  TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _save, child: Text(l10n.save)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
