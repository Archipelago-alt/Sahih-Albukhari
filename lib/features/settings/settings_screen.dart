import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../shared/context_ext.dart';
import '../backup/backup_service.dart';
import '../reader/reader_settings_sheet.dart';
import 'app_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.watch(settingsProvider);
    final c = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);
    Widget header(String t) => Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 8),
      child: Text(t, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            children: [
              header(l10n.settingsAppearance),
              ListTile(
                title: Text(l10n.settingsLanguage),
                trailing: DropdownButton<AppLanguage>(
                  value: s.language,
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(value: AppLanguage.system, child: Text(l10n.languageSystem)),
                    DropdownMenuItem(value: AppLanguage.ar, child: Text(l10n.languageArabic)),
                    DropdownMenuItem(value: AppLanguage.en, child: Text(l10n.languageEnglish)),
                  ],
                  onChanged: (v) => c.update((s) => s.copyWith(language: v)),
                ),
              ),
              ListTile(
                title: Text(l10n.settingsAppTheme),
                trailing: DropdownButton<ThemeMode>(
                  value: s.themeMode,
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(value: ThemeMode.system, child: Text(l10n.themeSystem)),
                    DropdownMenuItem(value: ThemeMode.light, child: Text(l10n.themeLight)),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n.themeDark)),
                  ],
                  onChanged: (v) => c.update((s) => s.copyWith(themeMode: v)),
                ),
              ),
              header(l10n.settingsReading),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: ReaderSettingsPanel(padded: false)),
              header(l10n.settingsSearchSection),
              SwitchListTile(
                title: Text(l10n.settingsSearchBroadDefault),
                value: s.searchBroadDefault,
                onChanged: (v) => c.update((s) => s.copyWith(searchBroadDefault: v)),
              ),
              SwitchListTile(
                title: Text(l10n.settingsSearchWholeWordsDefault),
                value: s.searchWholeWordsDefault,
                onChanged: (v) => c.update((s) => s.copyWith(searchWholeWordsDefault: v)),
              ),
              header(l10n.settingsTranslations),
              ListTile(title: Text(l10n.settingsTranslationsNone)),
              header(l10n.settingsData),
              ListTile(
                leading: const Icon(Icons.upload_file_outlined),
                title: Text(l10n.backupExport),
                subtitle: Text(l10n.backupExportDescription),
                onTap: () => _export(context, ref),
              ),
              ListTile(
                leading: const Icon(Icons.restore_outlined),
                title: Text(l10n.backupImport),
                subtitle: Text(l10n.backupImportDescription),
                onTap: () => _import(context, ref),
              ),
              ListTile(
                leading: const Icon(Icons.manage_search),
                title: Text(l10n.settingsClearSearchHistory),
                onTap: () async {
                  if (await context.confirm(
                    title: l10n.settingsClearSearchHistory,
                    message: l10n.clearSearchConfirm,
                    destructive: true,
                  )) {
                    await ref.read(userRepositoryProvider).clearSearchHistory();
                    if (context.mounted) context.showSnack(l10n.cleared);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.history_toggle_off),
                title: Text(l10n.settingsClearReadingHistory),
                onTap: () async {
                  if (await context.confirm(
                    title: l10n.settingsClearReadingHistory,
                    message: l10n.clearReadingConfirm,
                    destructive: true,
                  )) {
                    await ref.read(userRepositoryProvider).clearReadingHistory();
                    if (context.mounted) context.showSnack(l10n.cleared);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.remove_done),
                title: Text(l10n.settingsResetProgress),
                onTap: () async {
                  if (await context.confirm(
                    title: l10n.settingsResetProgress,
                    message: l10n.resetProgressConfirm,
                    destructive: true,
                  )) {
                    await ref.read(userRepositoryProvider).clearReadMarks();
                    if (context.mounted) context.showSnack(l10n.cleared);
                  }
                },
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.settingsAbout),
                onTap: () => context.push('/settings/about'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _sectionName(BuildContext context, BackupSection s) => switch (s) {
    BackupSection.bookmarks => context.l10n.backupSectionBookmarks,
    BackupSection.notes => context.l10n.backupSectionNotes,
    BackupSection.progress => context.l10n.backupSectionProgress,
    BackupSection.history => context.l10n.backupSectionHistory,
    BackupSection.settings => context.l10n.backupSectionSettings,
  };

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final chosen = {...BackupSection.values};
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.backupSections),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final s in BackupSection.values)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_sectionName(context, s)),
                  value: chosen.contains(s),
                  onChanged: (v) => setState(() => v! ? chosen.add(s) : chosen.remove(s)),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: chosen.isEmpty ? null : () => Navigator.pop(context, true),
              child: Text(l10n.backupExport),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      final content = ref.read(contentRepositoryProvider);
      final info = await content.info();
      final json = await ref
          .read(backupServiceProvider)
          .export(
            sections: chosen,
            appVersion: ref.read(appVersionProvider),
            contentSha256: info.sourceContentSha256 ?? '',
            numberByUid: await content.numberOfHadithUid(),
          );
      final dir = await getTemporaryDirectory();
      final date = DateTime.now().toIso8601String().substring(0, 10);
      final file = File('${dir.path}/sahih-albukhari-backup-$date.json');
      await file.writeAsString(json, flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          subject: l10n.backupExportSubject,
        ),
      );
    } catch (_) {
      if (context.mounted) context.showSnack(l10n.errorBody);
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final picked = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['json']);
    if (picked == null) return;
    final bytes = await picked.xFile.readAsBytes();
    if (!context.mounted) return;
    final content = ref.read(contentRepositoryProvider);
    final service = ref.read(backupServiceProvider);
    BackupData data;
    try {
      final String source;
      try {
        source = utf8.decode(bytes);
      } on FormatException {
        throw BackupFormatException(['the file is not UTF-8 text']);
      }
      data = service.parse(
        source,
        knownHadithUids: (await content.numberOfHadithUid()).keys.toSet(),
        knownStructureUids: await content.structureUids(),
      );
    } on BackupFormatException catch (e) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.backupInvalid),
          content: SingleChildScrollView(child: Text(e.problems.take(20).join('\n'), textDirection: TextDirection.ltr)),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close))],
        ),
      );
      return;
    }
    if (!context.mounted) return;
    final names = [
      for (final s in BackupSection.values)
        if (data.sections.contains(s)) _sectionName(context, s),
    ].join('، ');
    final ok = await context.confirm(
      title: l10n.backupImportConfirmTitle,
      message: l10n.backupImportConfirmBody(names),
      confirmLabel: l10n.backupImport,
      destructive: true,
    );
    if (!ok) return;
    await service.restore(data);
    if (data.sections.contains(BackupSection.settings)) await ref.read(settingsProvider.notifier).reload();
    if (context.mounted) context.showSnack(l10n.backupImportDone);
  }
}
