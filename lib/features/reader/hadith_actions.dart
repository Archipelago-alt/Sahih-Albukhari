import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../data/content/content_models.dart';
import '../../data/user/user_repository.dart';
import '../../shared/context_ext.dart';
import '../bookmarks/bookmark_editor.dart';
import '../notes/note_editor.dart';
import 'hadith_share_text.dart';

final noteProvider = StreamProvider.family<Note?, String>(
  (ref, uid) => ref.watch(userRepositoryProvider).watchNote(uid),
);

/// "صحيح البخاري، كتاب …، باب …، حديث رقم … (ج… ص…)".
String hadithReference(BuildContext context, Hadith h, Book book, Chapter? chapter) {
  final l10n = context.l10n;
  final page = l10n.pageReference(context.digits('${h.volume ?? ''}'), context.digits(h.printedPageStart ?? ''));
  final chapterTitle = chapter?.title;
  return chapterTitle == null || chapter!.isImplicit
      ? l10n.shareReferenceNoChapter(book.title, h.numberText, page)
      : l10n.shareReference(book.title, chapterTitle, h.numberText, page);
}

Future<void> editNote(BuildContext context, WidgetRef ref, String uid) async {
  final repo = ref.read(userRepositoryProvider);
  final existing = await repo.watchNote(uid).first;
  if (!context.mounted) return;
  await showNoteEditor(context, ref, hadithUid: uid, initial: existing?.body);
}

Future<void> showHadithActions(
  BuildContext context,
  WidgetRef ref, {
  required Hadith hadith,
  required List<FootnoteRef> footnotes,
  required Book book,
  required Chapter? chapter,
}) async {
  final l10n = context.l10n;
  final repo = ref.read(userRepositoryProvider);
  final bookmarked = ref.read(bookmarkedUidsProvider).value?.contains(hadith.uid) ?? false;
  final read = ref.read(readUidsProvider).value?.contains(hadith.uid) ?? false;
  final hasNote = ref.read(notedUidsProvider).value?.contains(hadith.uid) ?? false;
  final reference = hadithReference(context, hadith, book, chapter);

  final action = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(l10n.hadithNumberLabel(hadith.numberText), style: Theme.of(context).textTheme.titleMedium),
            ),
            ListTile(
              leading: Icon(bookmarked ? Icons.bookmark_remove_outlined : Icons.bookmark_add_outlined),
              title: Text(bookmarked ? l10n.readerRemoveBookmark : l10n.readerBookmark),
              onTap: () => Navigator.pop(context, 'bookmark'),
            ),
            if (bookmarked)
              ListTile(
                leading: const Icon(Icons.drive_file_rename_outline),
                title: Text(l10n.bookmarkEdit),
                onTap: () => Navigator.pop(context, 'bookmark_edit'),
              ),
            ListTile(
              leading: const Icon(Icons.sticky_note_2_outlined),
              title: Text(hasNote ? l10n.readerEditNote : l10n.readerAddNote),
              onTap: () => Navigator.pop(context, 'note'),
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text(l10n.readerCopy),
              onTap: () => Navigator.pop(context, 'copy'),
            ),
            if (footnotes.isNotEmpty || hadith.tuhfa != null)
              ListTile(
                leading: const Icon(Icons.copy_all),
                title: Text(l10n.readerCopyWithFootnotes),
                onTap: () => Navigator.pop(context, 'copy_notes'),
              ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: Text(l10n.readerShare),
              onTap: () => Navigator.pop(context, 'share'),
            ),
            ListTile(
              leading: Icon(read ? Icons.remove_done : Icons.done),
              title: Text(read ? l10n.readerMarkUnread : l10n.readerMarkRead),
              onTap: () => Navigator.pop(context, 'read'),
            ),
          ],
        ),
      ),
    ),
  );
  if (action == null || !context.mounted) return;
  switch (action) {
    case 'bookmark':
      final now = await repo.toggleBookmark(hadith.uid);
      if (context.mounted) context.showSnack(now ? l10n.bookmarkAdded : l10n.bookmarkRemoved);
    case 'bookmark_edit':
      await showBookmarkEditor(context, ref, hadithUid: hadith.uid);
    case 'note':
      await editNote(context, ref, hadith.uid);
    case 'copy':
      await Clipboard.setData(
        ClipboardData(
          text: HadithShareText.plain(hadith: hadith, reference: reference),
        ),
      );
      if (context.mounted) context.showSnack(l10n.readerCopied);
    case 'copy_notes':
      await Clipboard.setData(
        ClipboardData(
          text: HadithShareText.withEditorNotes(
            hadith: hadith,
            footnotes: footnotes,
            reference: reference,
            notesTitle: l10n.editorNotesTitle,
            tuhfaLabel: l10n.tuhfaLabel,
          ),
        ),
      );
      if (context.mounted) context.showSnack(l10n.readerCopied);
    case 'share':
      await SharePlus.instance.share(
        ShareParams(
          text: HadithShareText.plain(hadith: hadith, reference: reference),
        ),
      );
    case 'read':
      await repo.setRead([hadith.uid], read: !read);
  }
}
