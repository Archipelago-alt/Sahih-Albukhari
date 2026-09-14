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
SourceTextStyles readerTextStyles(AppSettings s, ReaderPalette p, {double scale = 1}) => SourceTextStyles(
  base: TextStyle(
    fontFamily: s.readingFont.family,
    fontFamilyFallback: s.readingFont.fallback,
    fontSize: s.fontSize * scale,
    height: s.lineHeight,
    color: p.text,
  ),
  emphasis: const TextStyle(fontWeight: FontWeight.w700),
  highlight: p.highlight,
);

/// Selectable source text, exactly as stored, with the source's emphasis and
/// any search highlights.
class SourceText extends StatelessWidget {
  const SourceText({
    super.key,
    required this.text,
    required this.styles,
    this.styleSpans = const [],
    this.highlights = const [],
    this.textAlign = TextAlign.justify,
  });

  final String text;
  final SourceTextStyles styles;
  final List<StyleSpan> styleSpans;
  final List<MatchRange> highlights;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final spans = buildSourceTextSpans(text: text, styles: styles, styleSpans: styleSpans, highlights: highlights);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SelectableText.rich(
        TextSpan(children: spans),
        textAlign: textAlign,
        textDirection: TextDirection.rtl,
      ),
    );
  }
}

class HadithView extends ConsumerStatefulWidget {
  const HadithView({super.key, required this.hadith, required this.book, required this.chapter, this.highlight});

  final Hadith hadith;
  final Book book;
  final Chapter? chapter;
  final SearchRequest? highlight;

  @override
  ConsumerState<HadithView> createState() => _HadithViewState();
}

class _HadithViewState extends ConsumerState<HadithView> {
  bool _tuhfaOpen = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final palette = ReaderPalette.resolve(settings.readerTheme, MediaQuery.platformBrightnessOf(context));
    final styles = readerTextStyles(settings, palette);
    final h = widget.hadith;
    final tuhfa = h.tuhfa;
    final bookmarked = ref.watch(bookmarkedUidsProvider).value?.contains(h.uid) ?? false;
    final read = ref.watch(readUidsProvider).value?.contains(h.uid) ?? false;
    final note = ref.watch(noteProvider(h.uid)).value;
    final highlights = widget.highlight == null
        ? const <MatchRange>[]
        : SearchHighlighter.find(h.text, widget.highlight!);
    final l10n = context.l10n;
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
              onPressed: () => showHadithActions(context, ref, hadith: h, book: widget.book, chapter: widget.chapter),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SourceText(text: h.text, styles: styles, styleSpans: h.spans, highlights: highlights),
        if (tuhfa != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: palette.muted),
              onPressed: () => setState(() => _tuhfaOpen = !_tuhfaOpen),
              icon: Icon(_tuhfaOpen ? Icons.expand_less : Icons.expand_more, size: 18),
              label: Text(_tuhfaOpen ? l10n.hideTuhfa : l10n.showTuhfa, style: labelStyle),
            ),
          ),
        if (_tuhfaOpen && tuhfa != null) _TuhfaReference(tuhfa: tuhfa, palette: palette),
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

/// The edition's Tuhfat al-Ashraf reference, set apart from the text and
/// labelled as the editor's addition.
class _TuhfaReference extends StatelessWidget {
  const _TuhfaReference({required this.tuhfa, required this.palette});

  final String tuhfa;
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
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        border: BorderDirectional(start: BorderSide(color: palette.divider, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.l10n.tuhfaDisclaimer, style: style.copyWith(fontSize: 12, fontFamily: 'NotoSansArabic')),
          const SizedBox(height: 4),
          Text('${context.l10n.tuhfaLabel}: $tuhfa', textDirection: TextDirection.rtl, style: style),
        ],
      ),
    );
  }
}
