/// Arabic normalization used only for searching.
///
/// The canonical text shown, copied, shared or exported is never passed
/// through this class. The rules are identical to
/// `tool/import/arabic_normalize.py`, which builds the search index; the test
/// `test/core/arabic_normalizer_test.dart` checks both against
/// `tool/import/normalization_vectors.json`.
library;

/// A normalized string plus, for every normalized character, the index of
/// the character in the original string it came from. Used to highlight
/// search matches in the untouched original text.
class NormalizedText {
  const NormalizedText(this.text, this.sourceIndex);

  final String text;

  /// `sourceIndex[i]` is the index in the original string of `text[i]`.
  final List<int> sourceIndex;
}

abstract final class ArabicNormalizer {
  static bool _isDiacritic(int c) =>
      (c >= 0x0610 && c <= 0x061A) ||
      (c >= 0x064B && c <= 0x065F) ||
      c == 0x0670 ||
      (c >= 0x06D6 && c <= 0x06DC) ||
      (c >= 0x06DF && c <= 0x06E8) ||
      (c >= 0x06EA && c <= 0x06ED) ||
      (c >= 0x08D3 && c <= 0x08E1) ||
      (c >= 0x08E3 && c <= 0x08FF) ||
      c == 0x0640; // tatweel

  /// True for marks the search normalization ignores (harakat, Quranic
  /// annotation marks, tatweel). Used to extend highlights over the marks
  /// that follow a matched letter.
  static bool isIgnorableMark(int codeUnit) => _isDiacritic(codeUnit);

  static bool _isWordChar(int c) =>
      (c >= 0x30 && c <= 0x39) ||
      (c >= 0x41 && c <= 0x5A) ||
      (c >= 0x61 && c <= 0x7A) ||
      (c >= 0x0621 && c <= 0x063A) ||
      (c >= 0x0641 && c <= 0x064A);

  static int _map(int c, bool broad) {
    switch (c) {
      case 0x0623: // أ
      case 0x0625: // إ
      case 0x0622: // آ
      case 0x0671: // ٱ
        return 0x0627;
      case 0x0649: // ى
        return 0x064A;
      case 0x0629: // ة
        return broad ? 0x0647 : c;
    }
    if (c >= 0x0660 && c <= 0x0669) return 0x30 + (c - 0x0660);
    if (c >= 0x06F0 && c <= 0x06F9) return 0x30 + (c - 0x06F0);
    return c;
  }

  /// Normalizes [input] for searching. See the library documentation.
  static String normalize(String input, {bool broad = false}) => normalizeWithMap(input, broad: broad).text;

  /// Like [normalize], but also returns the source index of every character.
  static NormalizedText normalizeWithMap(String input, {bool broad = false}) {
    final out = StringBuffer();
    final index = <int>[];
    var pendingSpace = false;
    for (var i = 0; i < input.length; i++) {
      final c = input.codeUnitAt(i);
      if (_isDiacritic(c)) continue;
      final m = _map(c, broad);
      if (_isWordChar(m)) {
        if (pendingSpace && index.isNotEmpty) {
          out.writeCharCode(0x20);
          index.add(i);
        }
        pendingSpace = false;
        out.writeCharCode(m);
        index.add(i);
      } else {
        pendingSpace = true;
      }
    }
    return NormalizedText(out.toString(), index);
  }

  /// Converts Arabic-Indic / Extended Arabic-Indic digits to ASCII digits.
  static String toWesternDigits(String input) => String.fromCharCodes(
    input.codeUnits.map((c) {
      if (c >= 0x0660 && c <= 0x0669) return 0x30 + (c - 0x0660);
      if (c >= 0x06F0 && c <= 0x06F9) return 0x30 + (c - 0x06F0);
      return c;
    }),
  );

  /// Converts ASCII digits to Arabic-Indic digits (for display in Arabic).
  static String toArabicDigits(String input) =>
      String.fromCharCodes(input.codeUnits.map((c) => (c >= 0x30 && c <= 0x39) ? 0x0660 + (c - 0x30) : c));
}
