import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/content/content_models.dart';
import '../../data/content/search_repository.dart';
import '../../shared/context_ext.dart';
import '../search/search_highlighter.dart';
import '../settings/app_settings.dart';
import 'hadith_actions.dart';
import 'source_text_spans.dart';

/// Styles derived from the reader settings and palette.
SourceTextStyles readerTextStyles(AppSettings s, ReaderPalette p, {double scale = 1}) {
  final base = TextStyle(
    fontFamily: s.readingFont.family,
    fontFamilyFallback: s.readingFont.fallback,
    fontSize: s.fontSize * scale,
    height: s.lineHeight,
    color: p.text,
  );
  return SourceTextStyles(
    base: base,
    emphasis: const TextStyle(fontWeight: FontWeight.w700),
    marker: base.copyWith(fontSize: s.fontSize * scale * 0.6, color: p.marker, height: 1),
    highlight: p.highlight,
  );
}

/// Selectable source text with footnote markers that open the note.
class SourceText extends StatefulWidget {
  const SourceText({
    super.key,
    required this.text,
    required this.styles,
    this.styleSpans = const [],
    this.markers = const [],
    this.highlights = const [],
    this.showMarkers = true,
    this.textAlign = TextAlign.justify,
  });

  final String text;
  final SourceTextStyles styles;
  final List<StyleSpan> styleSpans;
  final List<FootnoteRef> markers;
  final List<MatchRange> highlights;
  final bool showMarkers;
  final TextAlign textAlign;

  @override
  State<SourceText> createState() => _SourceTextState();
}

class _SourceTextState extends State<SourceText> {
  final _recognizers = <TapGestureRecognizer>[];

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final spans = buildSourceTextSpans(
      text: widget.text,
      styles: widget.styles,
      styleSpans: widget.styleSpans,
      markers: widget.markers,
      highlights: widget.highlights,
      showMarkers: widget.showMarkers,
      markerRecognizer: (ref) {
        final r = TapGestureRecognizer()..onTap = () => showFootnoteSheet(context, ref);
        _recognizers.add(r);
        return r;
      },
    );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SelectableText.rich(
        TextSpan(children: spans),
        textAlign: widget.textAlign,
        textDirection: TextDirection.rtl,
      ),
    );
  }
}

Future<void> showFootnoteSheet(BuildContext context, FootnoteRef ref) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.l10n.footnoteTitle(ref.marker), style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              context.l10n.editorNotesDisclaimer,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const Divider(height: 24),
            Text(
              ref.footnoteText ?? context.l10n.footnoteMissing,
              textDirection: TextDirection.rtl,
              style: theme.textTheme.bodyLarge?.copyWith(fontFamily: 'NotoNaskhArabic', height: 1.8),
            ),
          ],
        ),
      ),
    );
  },
);

class HadithView extends ConsumerStatefulWidget {
  const HadithView({
    super.key,
    required this.hadith,
    required this.footnotes,
    required this.book,
    required this.chapter,
    this.highlight,
  });

  final Hadith hadith;
  final List<FootnoteRef> footnotes;
  final Book book;
  final Chapter? chapter;
  final SearchRequest? highlight;

  @override
  ConsumerState<HadithView> createState() => _HadithViewState();
}

class _HadithViewState extends ConsumerState<HadithView> {
  bool _notesOpen = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final palette = ReaderPalette.resolve(settings.readerTheme, MediaQuery.platformBrightnessOf(context));
    final styles = readerTextStyles(settings, palette);
    final h = widget.hadith;
    final bookmarked = ref.watch(bookmarkedUidsProvider).value?.contains(h.uid) ?? false;
    final read = ref.watch(readUidsProvider).value?.contains(h.uid) ?? false;
    final note = ref.watch(noteProvider(h.uid)).value;
    final highlights = widget.highlight == null
        ? const <MatchRange>[]
        : SearchHighlighter.find(h.text, widget.highlight!);
    final l10n = context.l10n;
    final hasEditorNotes = widget.footnotes.isNotEmpty || h.tuhfa != null;
    final labelStyle = TextStyle(fontFamily: 'NotoSansArabic', fontSize: 14, color: palette.muted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Semantics(
              header: true,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: palette.divider),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.hadithNumberLabel(h.numberText),
                  style: labelStyle.copyWith(color: palette.heading, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (bookmarked) Icon(Icons.bookmark, size: 18, color: palette.heading, semanticLabel: l10n.readerBookmark),
            if (note != null)
              Icon(Icons.sticky_note_2_outlined, size: 18, color: palette.muted, semanticLabel: l10n.noteEditorTitle),
            if (read) Icon(Icons.done, size: 18, color: palette.muted, semanticLabel: l10n.readerRead),
            const Spacer(),
            IconButton(
              tooltip: l10n.readerMore,
              color: palette.muted,
              icon: const Icon(Icons.more_horiz),
              onPressed: () => showHadithActions(
                context,
                ref,
                hadith: h,
                footnotes: widget.footnotes,
                book: widget.book,
                chapter: widget.chapter,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SourceText(
          text: h.text,
          styles: styles,
          styleSpans: h.spans,
          markers: widget.footnotes,
          highlights: highlights,
          showMarkers: settings.showFootnoteMarkers,
        ),
        if (hasEditorNotes)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: palette.muted),
              onPressed: () => setState(() => _notesOpen = !_notesOpen),
              icon: Icon(_notesOpen ? Icons.expand_less : Icons.expand_more, size: 18),
              label: Text(_notesOpen ? l10n.hideEditorNotes : l10n.showEditorNotes, style: labelStyle),
            ),
          ),
        if (_notesOpen && hasEditorNotes) _EditorNotes(hadith: h, footnotes: widget.footnotes, palette: palette),
        if (note != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Material(
              color: palette.noteBackground,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => editNote(context, ref, h.uid),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lock_outline, size: 16, color: palette.muted),
                          const SizedBox(width: 6),
                          Expanded(child: Text(l10n.notePrivateBadge, style: labelStyle.copyWith(fontSize: 12))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        note.body,
                        style: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 15, color: palette.text, height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _EditorNotes extends StatelessWidget {
  const _EditorNotes({required this.hadith, required this.footnotes, required this.palette});

  final Hadith hadith;
  final List<FootnoteRef> footnotes;
  final ReaderPalette palette;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: 'NotoNaskhArabic',
      fontFamilyFallback: const ['Amiri'],
      fontSize: 15,
      height: 1.8,
      color: palette.muted,
    );
    final seen = <int?>{};
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        border: BorderDirectional(start: BorderSide(color: palette.divider, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.editorNotesTitle,
            style: style.copyWith(fontWeight: FontWeight.w700, fontFamily: 'NotoSansArabic', fontSize: 13),
          ),
          Text(context.l10n.editorNotesDisclaimer, style: style.copyWith(fontSize: 12, fontFamily: 'NotoSansArabic')),
          const SizedBox(height: 6),
          for (final f in footnotes)
            if (seen.add(f.footnoteId))
              Text(
                '${f.marker} ${f.footnoteText ?? context.l10n.footnoteMissing}',
                textDirection: TextDirection.rtl,
                style: style,
              ),
          if (hadith.tuhfa != null)
            Text('${context.l10n.tuhfaLabel}: ${hadith.tuhfa}', textDirection: TextDirection.rtl, style: style),
        ],
      ),
    );
  }
}
