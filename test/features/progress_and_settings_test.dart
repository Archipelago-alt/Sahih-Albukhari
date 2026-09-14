import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahih_albukhari/app/theme.dart';
import 'package:sahih_albukhari/features/progress/progress_calculator.dart';
import 'package:sahih_albukhari/features/settings/app_settings.dart';

void main() {
  group('ProgressCalculator', () {
    test('counts only known hadiths, per book and overall', () {
      final p = ProgressCalculator.compute(
        readUids: {'h1', 'h2', 'h8', 'unknown'},
        bookOfUid: {'h1': 1, 'h2': 1, 'h3': 1, 'h8': 2, 'h9': 2},
        hadithCountByBook: {1: 3, 2: 2},
      );
      expect(p.overall, const ReadingProgress(3, 5));
      expect(p.byBook[1], const ReadingProgress(2, 3));
      expect(p.byBook[2], const ReadingProgress(1, 2));
      expect(p.overall.percent, 60);
    });

    test('empty and complete states', () {
      expect(ReadingProgress.empty.fraction, 0);
      expect(const ReadingProgress(0, 10).percent, 0);
      expect(const ReadingProgress(10, 10).isComplete, isTrue);
      expect(const ReadingProgress(2, 3).percent, 66);
    });
  });

  group('AppSettings', () {
    test('defaults are Arabic-first', () {
      const s = AppSettings();
      expect(s.language, AppLanguage.ar);
      expect(s.locale, const Locale('ar'));
    });

    test('round-trips through the key/value store', () {
      const s = AppSettings(
        language: AppLanguage.en,
        themeMode: ThemeMode.dark,
        readerTheme: ReaderThemeMode.sepia,
        readingFont: ReadingFont.notoNaskh,
        fontSize: 30,
        lineHeight: 2.2,
        pagePadding: 32,
        keepAwake: true,
        showFootnoteMarkers: false,
        searchBroadDefault: true,
        searchWholeWordsDefault: true,
      );
      expect(AppSettings.fromMap(s.toMap()), s);
    });

    test('malformed or out-of-range values fall back safely', () {
      final s = AppSettings.fromMap({'font_size': '999', 'line_height': 'x', 'reader_theme': 'neon'});
      expect(s.fontSize, AppSettings.maxFontSize);
      expect(s.lineHeight, const AppSettings().lineHeight);
      expect(s.readerTheme, ReaderThemeMode.system);
    });
  });
}
