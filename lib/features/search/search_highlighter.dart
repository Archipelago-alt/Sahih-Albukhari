import '../../core/arabic/arabic_normalizer.dart';
import '../../data/content/search_repository.dart';

/// A half-open range `[start, end)` in the ORIGINAL (untouched) text.
class MatchRange {
  const MatchRange(this.start, this.end);

  final int start;
  final int end;

  @override
  bool operator ==(Object other) => other is MatchRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'MatchRange($start, $end)';
}

class Snippet {
  const Snippet(this.text, this.matches, {required this.clippedStart, required this.clippedEnd});

  /// A substring of the original text (never modified).
  final String text;

  /// Match ranges relative to [text].
  final List<MatchRange> matches;
  final bool clippedStart;
  final bool clippedEnd;
}

/// Locates search matches inside original text, so highlights can be drawn
/// on the untouched text while matching is done on the normalized form.
abstract final class SearchHighlighter {
  static List<MatchRange> find(String original, SearchRequest request) {
    if (request.isEmpty) return const [];
    final ranges = <MatchRange>[];
    if (request.mode == SearchMode.exact) {
      final needle = request.query.trim();
      var i = original.indexOf(needle);
      while (i >= 0) {
        ranges.add(MatchRange(i, i + needle.length));
        i = original.indexOf(needle, i + needle.length);
      }
      return ranges;
    }
    final nt = ArabicNormalizer.normalizeWithMap(original, broad: request.broad);
    final hay = nt.text;
    final needles = request.mode == SearchMode.phrase ? [request.normalized] : request.tokens.toSet().toList();
    for (final needle in needles) {
      if (needle.isEmpty) continue;
      var i = hay.indexOf(needle);
      while (i >= 0) {
        final end = i + needle.length;
        final boundaryOk =
            !request.wholeWords ||
            ((i == 0 || hay.codeUnitAt(i - 1) == 0x20) && (end == hay.length || hay.codeUnitAt(end) == 0x20));
        if (boundaryOk) {
          final start = nt.sourceIndex[i];
          var stop = nt.sourceIndex[end - 1] + 1;
          // Include the diacritics written on the last matched letter.
          while (stop < original.length && ArabicNormalizer.isIgnorableMark(original.codeUnitAt(stop))) {
            stop++;
          }
          ranges.add(MatchRange(start, stop));
        }
        i = hay.indexOf(needle, i + 1);
      }
    }
    return _merge(ranges);
  }

  static List<MatchRange> _merge(List<MatchRange> ranges) {
    if (ranges.length < 2) return ranges;
    final sorted = [...ranges]..sort((a, b) => a.start.compareTo(b.start));
    final out = <MatchRange>[sorted.first];
    for (final r in sorted.skip(1)) {
      final last = out.last;
      if (r.start <= last.end) {
        out[out.length - 1] = MatchRange(last.start, r.end > last.end ? r.end : last.end);
      } else {
        out.add(r);
      }
    }
    return out;
  }

  /// A short excerpt of [original] around the first match, cut at spaces.
  static Snippet snippet(String original, List<MatchRange> matches, {int context = 70}) {
    if (matches.isEmpty) {
      final end = _cutForward(original, context * 2);
      return Snippet(original.substring(0, end), const [], clippedStart: false, clippedEnd: end < original.length);
    }
    final first = matches.first;
    var start = first.start - context;
    var end = first.end + context;
    start = start <= 0 ? 0 : _cutBackward(original, start);
    end = end >= original.length ? original.length : _cutForward(original, end);
    final text = original.substring(start, end);
    final local = [
      for (final m in matches)
        if (m.start >= start && m.end <= end) MatchRange(m.start - start, m.end - start),
    ];
    return Snippet(text, local, clippedStart: start > 0, clippedEnd: end < original.length);
  }

  static int _cutBackward(String s, int i) {
    final j = s.lastIndexOf(RegExp(r'\s'), i);
    return j < 0 ? 0 : j + 1;
  }

  static int _cutForward(String s, int i) {
    if (i >= s.length) return s.length;
    final j = s.indexOf(RegExp(r'\s'), i);
    return j < 0 ? s.length : j;
  }
}
