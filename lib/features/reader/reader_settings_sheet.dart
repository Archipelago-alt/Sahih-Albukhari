import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../shared/context_ext.dart';
import '../settings/app_settings.dart';

Future<void> showReaderSettings(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (context) => const ReaderSettingsPanel(),
);

/// Reader appearance controls; changes apply immediately and persist.
class ReaderSettingsPanel extends ConsumerWidget {
  const ReaderSettingsPanel({super.key, this.padded = true});

  final bool padded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final c = ref.read(settingsProvider.notifier);
    final l10n = context.l10n;
    final theme = Theme.of(context);
    Widget label(String t) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(t, style: theme.textTheme.titleSmall),
    );
    return SafeArea(
      child: SingleChildScrollView(
        padding: padded ? const EdgeInsets.fromLTRB(20, 0, 20, 24) : EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            label(l10n.settingsReaderTheme),
            SegmentedButton<ReaderThemeMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: ReaderThemeMode.system, label: Text(l10n.readerThemeSystem)),
                ButtonSegment(value: ReaderThemeMode.light, label: Text(l10n.readerThemeLight)),
                ButtonSegment(value: ReaderThemeMode.sepia, label: Text(l10n.readerThemeSepia)),
                ButtonSegment(value: ReaderThemeMode.dark, label: Text(l10n.readerThemeDark)),
              ],
              selected: {s.readerTheme},
              onSelectionChanged: (v) => c.update((s) => s.copyWith(readerTheme: v.first)),
            ),
            label(l10n.settingsReadingFont),
            SegmentedButton<ReadingFont>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: ReadingFont.amiri, label: Text(l10n.fontAmiri)),
                ButtonSegment(value: ReadingFont.notoNaskh, label: Text(l10n.fontNotoNaskh)),
              ],
              selected: {s.readingFont},
              onSelectionChanged: (v) => c.update((s) => s.copyWith(readingFont: v.first)),
            ),
            label('${l10n.settingsFontSize} (${context.number(s.fontSize.round())})'),
            Slider(
              min: AppSettings.minFontSize,
              max: AppSettings.maxFontSize,
              divisions: (AppSettings.maxFontSize - AppSettings.minFontSize).round(),
              value: s.fontSize,
              label: context.number(s.fontSize.round()),
              semanticFormatterCallback: (v) => context.number(v.round()),
              onChanged: (v) => c.update((s) => s.copyWith(fontSize: v)),
            ),
            label(l10n.settingsLineHeight),
            Slider(
              min: AppSettings.minLineHeight,
              max: AppSettings.maxLineHeight,
              divisions: 13,
              value: s.lineHeight,
              label: s.lineHeight.toStringAsFixed(1),
              onChanged: (v) => c.update((s) => s.copyWith(lineHeight: v)),
            ),
            label(l10n.settingsPagePadding),
            Slider(
              min: AppSettings.minPadding,
              max: AppSettings.maxPadding,
              divisions: 10,
              value: s.pagePadding,
              label: context.number(s.pagePadding.round()),
              onChanged: (v) => c.update((s) => s.copyWith(pagePadding: v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsShowFootnoteMarkers),
              value: s.showFootnoteMarkers,
              onChanged: (v) => c.update((s) => s.copyWith(showFootnoteMarkers: v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsKeepAwake),
              value: s.keepAwake,
              onChanged: (v) => c.update((s) => s.copyWith(keepAwake: v)),
            ),
          ],
        ),
      ),
    );
  }
}
