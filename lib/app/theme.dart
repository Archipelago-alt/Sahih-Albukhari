import 'package:flutter/material.dart';

/// Colours and typography of the app and of the reading surface.
abstract final class AppTheme {
  static const Color brandGreen = Color(0xFF1B5E46);

  /// Interface font (Arabic + Latin fallback).
  static const String uiFont = 'NotoSansArabic';

  /// Fallbacks cover glyphs a font lacks (e.g. Amiri has no Unicode 14
  /// honorific ligatures; the Noto fonts have no ASCII punctuation).
  static const List<String> uiFallback = ['Amiri', 'NotoNaskhArabic'];

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: brandGreen, brightness: brightness);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: uiFont,
      fontFamilyFallback: uiFallback,
      visualDensity: VisualDensity.standard,
    );
    return base.copyWith(
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        scrolledUnderElevation: 1,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 0.6),
      listTileTheme: const ListTileThemeData(contentPadding: EdgeInsetsDirectional.only(start: 20, end: 16)),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}

enum ReaderThemeMode { system, light, sepia, dark }

/// Colours of the reading surface only.
class ReaderPalette {
  const ReaderPalette({
    required this.background,
    required this.text,
    required this.heading,
    required this.muted,
    required this.divider,
    required this.highlight,
    required this.marker,
    required this.noteBackground,
    required this.brightness,
  });

  final Color background;
  final Color text;
  final Color heading;
  final Color muted;
  final Color divider;
  final Color highlight;
  final Color marker;
  final Color noteBackground;
  final Brightness brightness;

  static const light = ReaderPalette(
    background: Color(0xFFFCFCFA),
    text: Color(0xFF1B1C1A),
    heading: Color(0xFF1B5E46),
    muted: Color(0xFF5F635E),
    divider: Color(0xFFDADDD6),
    highlight: Color(0x66F2C94C),
    marker: Color(0xFF8A6D3B),
    noteBackground: Color(0xFFEFF4EF),
    brightness: Brightness.light,
  );

  static const sepia = ReaderPalette(
    background: Color(0xFFF5ECD9),
    text: Color(0xFF3A2E1F),
    heading: Color(0xFF5B4221),
    muted: Color(0xFF7A6A52),
    divider: Color(0xFFD9CBB0),
    highlight: Color(0x66E0A93B),
    marker: Color(0xFF8C5A2B),
    noteBackground: Color(0xFFEBE0C8),
    brightness: Brightness.light,
  );

  static const dark = ReaderPalette(
    background: Color(0xFF121412),
    text: Color(0xFFE4E2DC),
    heading: Color(0xFF8FD1B2),
    muted: Color(0xFFA2A69F),
    divider: Color(0xFF2E322E),
    highlight: Color(0x66B8962E),
    marker: Color(0xFFD0B27A),
    noteBackground: Color(0xFF1D241F),
    brightness: Brightness.dark,
  );

  static ReaderPalette resolve(ReaderThemeMode mode, Brightness platform) => switch (mode) {
    ReaderThemeMode.light => light,
    ReaderThemeMode.sepia => sepia,
    ReaderThemeMode.dark => dark,
    ReaderThemeMode.system => platform == Brightness.dark ? dark : light,
  };
}

enum ReadingFont {
  amiri('Amiri', ['NotoNaskhArabic']),
  notoNaskh('NotoNaskhArabic', ['Amiri']);

  const ReadingFont(this.family, this.fallback);
  final String family;
  final List<String> fallback;
}
