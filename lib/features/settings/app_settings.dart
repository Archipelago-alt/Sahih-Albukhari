import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';

enum AppLanguage { system, ar, en }

/// User preferences, persisted as key/value pairs in the user database.
@immutable
class AppSettings {
  const AppSettings({
    this.language = AppLanguage.ar,
    this.themeMode = ThemeMode.system,
    this.readerTheme = ReaderThemeMode.system,
    this.readingFont = ReadingFont.amiri,
    this.fontSize = 22,
    this.lineHeight = 1.9,
    this.pagePadding = 20,
    this.keepAwake = false,
    this.showFootnoteMarkers = true,
    this.searchBroadDefault = false,
    this.searchWholeWordsDefault = false,
  });

  static const double minFontSize = 14;
  static const double maxFontSize = 44;
  static const double minLineHeight = 1.3;
  static const double maxLineHeight = 2.6;
  static const double minPadding = 8;
  static const double maxPadding = 48;

  final AppLanguage language;
  final ThemeMode themeMode;
  final ReaderThemeMode readerTheme;
  final ReadingFont readingFont;
  final double fontSize;
  final double lineHeight;
  final double pagePadding;
  final bool keepAwake;
  final bool showFootnoteMarkers;
  final bool searchBroadDefault;
  final bool searchWholeWordsDefault;

  Locale? get locale => switch (language) {
    AppLanguage.system => null,
    AppLanguage.ar => const Locale('ar'),
    AppLanguage.en => const Locale('en'),
  };

  AppSettings copyWith({
    AppLanguage? language,
    ThemeMode? themeMode,
    ReaderThemeMode? readerTheme,
    ReadingFont? readingFont,
    double? fontSize,
    double? lineHeight,
    double? pagePadding,
    bool? keepAwake,
    bool? showFootnoteMarkers,
    bool? searchBroadDefault,
    bool? searchWholeWordsDefault,
  }) => AppSettings(
    language: language ?? this.language,
    themeMode: themeMode ?? this.themeMode,
    readerTheme: readerTheme ?? this.readerTheme,
    readingFont: readingFont ?? this.readingFont,
    fontSize: fontSize ?? this.fontSize,
    lineHeight: lineHeight ?? this.lineHeight,
    pagePadding: pagePadding ?? this.pagePadding,
    keepAwake: keepAwake ?? this.keepAwake,
    showFootnoteMarkers: showFootnoteMarkers ?? this.showFootnoteMarkers,
    searchBroadDefault: searchBroadDefault ?? this.searchBroadDefault,
    searchWholeWordsDefault: searchWholeWordsDefault ?? this.searchWholeWordsDefault,
  );

  Map<String, String> toMap() => {
    'language': language.name,
    'theme_mode': themeMode.name,
    'reader_theme': readerTheme.name,
    'reading_font': readingFont.name,
    'font_size': fontSize.toString(),
    'line_height': lineHeight.toString(),
    'page_padding': pagePadding.toString(),
    'keep_awake': keepAwake.toString(),
    'show_footnote_markers': showFootnoteMarkers.toString(),
    'search_broad': searchBroadDefault.toString(),
    'search_whole_words': searchWholeWordsDefault.toString(),
  };

  /// Unknown or malformed values fall back to the defaults.
  factory AppSettings.fromMap(Map<String, String> m) {
    const d = AppSettings();
    T pick<T extends Enum>(List<T> values, String? name, T fallback) =>
        values.where((v) => v.name == name).firstOrNull ?? fallback;
    double num(String? v, double fallback, double min, double max) {
      final x = double.tryParse(v ?? '');
      return x == null ? fallback : x.clamp(min, max);
    }

    bool flag(String? v, bool fallback) => v == null ? fallback : v == 'true';
    return AppSettings(
      language: pick(AppLanguage.values, m['language'], d.language),
      themeMode: pick(ThemeMode.values, m['theme_mode'], d.themeMode),
      readerTheme: pick(ReaderThemeMode.values, m['reader_theme'], d.readerTheme),
      readingFont: pick(ReadingFont.values, m['reading_font'], d.readingFont),
      fontSize: num(m['font_size'], d.fontSize, minFontSize, maxFontSize),
      lineHeight: num(m['line_height'], d.lineHeight, minLineHeight, maxLineHeight),
      pagePadding: num(m['page_padding'], d.pagePadding, minPadding, maxPadding),
      keepAwake: flag(m['keep_awake'], d.keepAwake),
      showFootnoteMarkers: flag(m['show_footnote_markers'], d.showFootnoteMarkers),
      searchBroadDefault: flag(m['search_broad'], d.searchBroadDefault),
      searchWholeWordsDefault: flag(m['search_whole_words'], d.searchWholeWordsDefault),
    );
  }

  @override
  bool operator ==(Object other) => other is AppSettings && _mapEquals(other.toMap(), toMap());

  @override
  int get hashCode => Object.hashAll(toMap().values);

  static bool _mapEquals(Map<String, String> a, Map<String, String> b) =>
      a.length == b.length && a.keys.every((k) => a[k] == b[k]);
}

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(initialSettingsProvider);

  /// Re-reads the stored settings (after a backup restore).
  Future<void> reload() async {
    state = AppSettings.fromMap(await ref.read(userRepositoryProvider).settings());
  }

  Future<void> update(AppSettings Function(AppSettings s) change) async {
    final next = change(state);
    if (next == state) return;
    final before = state.toMap();
    state = next;
    final repo = ref.read(userRepositoryProvider);
    for (final e in next.toMap().entries) {
      if (before[e.key] != e.value) await repo.setSetting(e.key, e.value);
    }
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
