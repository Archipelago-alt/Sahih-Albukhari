import '../../data/content/content_models.dart';
import 'source_text_spans.dart';

/// Composes the text placed on the clipboard or shared. The hadith text is
/// always the untouched canonical text; the reference follows it on its own
/// paragraph, separated by a blank line.
abstract final class HadithShareText {
  static String plain({required Hadith hadith, required String reference}) => '${hadith.text}\n\n$reference';

  static String withEditorNotes({
    required Hadith hadith,
    required List<FootnoteRef> footnotes,
    required String reference,
    required String notesTitle,
    required String tuhfaLabel,
  }) {
    final b = StringBuffer(textWithMarkers(hadith.text, footnotes));
    final seen = <String>{};
    final lines = [
      for (final f in footnotes)
        if (f.footnoteText != null && seen.add('${f.footnoteId}')) '${f.marker} ${f.footnoteText}',
    ];
    if (lines.isNotEmpty || hadith.tuhfa != null) {
      b
        ..write('\n\n— $notesTitle —\n')
        ..write(lines.join('\n'));
      if (hadith.tuhfa != null) {
        if (lines.isNotEmpty) b.write('\n');
        b.write('$tuhfaLabel: ${hadith.tuhfa}');
      }
    }
    b.write('\n\n$reference');
    return b.toString();
  }
}
