import '../../data/content/content_models.dart';

/// Composes the text placed on the clipboard or shared. The hadith text is
/// always the untouched canonical text; the reference follows it on its own
/// paragraph, separated by a blank line.
abstract final class HadithShareText {
  static String plain({required Hadith hadith, required String reference}) => '${hadith.text}\n\n$reference';

  /// The text, then the edition's Tuhfat al-Ashraf reference (when the source
  /// has one), then the reference line.
  static String withTuhfa({required Hadith hadith, required String reference, required String tuhfaLabel}) {
    final tuhfa = hadith.tuhfa;
    if (tuhfa == null) return plain(hadith: hadith, reference: reference);
    return '${hadith.text}\n\n$tuhfaLabel: $tuhfa\n\n$reference';
  }
}
