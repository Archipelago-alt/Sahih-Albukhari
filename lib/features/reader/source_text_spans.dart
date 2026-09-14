import 'package:flutter/painting.dart';

import '../../data/content/content_models.dart';
import '../search/search_highlighter.dart';

class SourceTextStyles {
  const SourceTextStyles({required this.base, required this.emphasis, required this.highlight});

  final TextStyle base;

  /// Applied to ranges the source marks as emphasised (span.c1: the bold
  /// matn of the print).
  final TextStyle emphasis;
  final Color highlight;
}

/// Builds the spans of an untouched source text. The characters of [text]
/// are emitted unchanged and in order; styling and search highlights are
/// layered on top.
List<InlineSpan> buildSourceTextSpans({
  required String text,
  required SourceTextStyles styles,
  List<StyleSpan> styleSpans = const [],
  List<MatchRange> highlights = const [],
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
  final points = cuts.toList()..sort();

  final spans = <InlineSpan>[];
  for (var i = 0; i < points.length - 1; i++) {
    final a = points[i];
    final b = points[i + 1];
    var style = styles.base;
    if (emphasis.any((s) => s.start <= a && s.end >= b)) style = style.merge(styles.emphasis);
    if (highlights.any((h) => h.start <= a && h.end >= b)) {
      style = style.copyWith(backgroundColor: styles.highlight);
    }
    spans.add(TextSpan(text: text.substring(a, b), style: style));
  }
  return spans;
}
