import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';

import '../../data/content/content_models.dart';
import '../search/search_highlighter.dart';

class SourceTextStyles {
  const SourceTextStyles({required this.base, required this.emphasis, required this.marker, required this.highlight});

  final TextStyle base;

  /// Applied to ranges the source marks as emphasised (span.c1: the bold
  /// matn of the print).
  final TextStyle emphasis;
  final TextStyle marker;
  final Color highlight;
}

/// Builds the spans of an untouched source text. The characters of [text]
/// are emitted unchanged and in order; styling, search highlights and the
/// editor's footnote markers are layered on top. Markers are inserted as
/// separate spans at their recorded offsets (only when [showMarkers]).
List<InlineSpan> buildSourceTextSpans({
  required String text,
  required SourceTextStyles styles,
  List<StyleSpan> styleSpans = const [],
  List<FootnoteRef> markers = const [],
  List<MatchRange> highlights = const [],
  bool showMarkers = true,
  GestureRecognizer? Function(FootnoteRef ref)? markerRecognizer,
}) {
  final len = text.length;
  final cuts = <int>{0, len};
  final emphasis = [
    for (final s in styleSpans)
      if (s.style == 'c1') s,
  ];
  for (final s in emphasis) {
    cuts
      ..add(s.start.clamp(0, len))
      ..add(s.end.clamp(0, len));
  }
  for (final h in highlights) {
    cuts
      ..add(h.start.clamp(0, len))
      ..add(h.end.clamp(0, len));
  }
  final shown = showMarkers ? markers : const <FootnoteRef>[];
  for (final m in shown) {
    cuts.add(m.offset.clamp(0, len));
  }
  final points = cuts.toList()..sort();
  final markersAt = <int, List<FootnoteRef>>{};
  for (final m in shown) {
    markersAt.putIfAbsent(m.offset.clamp(0, len), () => []).add(m);
  }

  final spans = <InlineSpan>[];
  void addMarkers(int at) {
    for (final m in markersAt[at] ?? const <FootnoteRef>[]) {
      spans.add(TextSpan(text: m.marker, style: styles.marker, recognizer: markerRecognizer?.call(m)));
    }
  }

  for (var i = 0; i < points.length - 1; i++) {
    final a = points[i];
    final b = points[i + 1];
    addMarkers(a);
    if (a == b) continue;
    var style = styles.base;
    if (emphasis.any((s) => s.start <= a && s.end >= b)) style = style.merge(styles.emphasis);
    if (highlights.any((h) => h.start <= a && h.end >= b)) {
      style = style.copyWith(backgroundColor: styles.highlight);
    }
    spans.add(TextSpan(text: text.substring(a, b), style: style));
  }
  if (len > 0 || markersAt.containsKey(0)) addMarkers(len);
  return spans;
}

/// Re-inserts the footnote markers into [text] (for "copy with notes").
String textWithMarkers(String text, List<FootnoteRef> markers) {
  final sorted = [...markers]..sort((a, b) => a.offset.compareTo(b.offset));
  final out = StringBuffer();
  var pos = 0;
  for (final m in sorted) {
    final at = m.offset.clamp(0, text.length);
    out
      ..write(text.substring(pos, at))
      ..write(m.marker);
    pos = at;
  }
  out.write(text.substring(pos));
  return out.toString();
}
