import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/arabic/arabic_normalizer.dart';
import '../../data/content/content_models.dart';
import '../../data/user/user_repository.dart';
import '../../shared/context_ext.dart';
import '../../shared/state_views.dart';
import '../settings/app_settings.dart';
import 'hadith_view.dart';
import 'reader_outline.dart';
import 'reader_settings_sheet.dart';
import 'reader_target.dart';
import 'source_text_spans.dart';

class ReaderScreen extends ConsumerWidget {
  const ReaderScreen({super.key, required this.target});

  final ReaderTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outline = ref.watch(readerOutlineProvider(target.bookId));
    return outline.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (e, st) => Scaffold(
        appBar: AppBar(),
        body: ErrorView(onRetry: () => ref.invalidate(readerOutlineProvider(target.bookId))),
      ),
      data: (o) => _Reader(key: ValueKey(target.location), outline: o, target: target),
    );
  }
}

class _Reader extends ConsumerStatefulWidget {
  const _Reader({super.key, required this.outline, required this.target});

  final ReaderOutline outline;
  final ReaderTarget target;

  @override
  ConsumerState<_Reader> createState() => _ReaderState();
}

class _ReaderState extends ConsumerState<_Reader> with WidgetsBindingObserver {
  final _items = ItemScrollController();
  final _positions = ItemPositionsListener.create();
  final _top = ValueNotifier<int>(0);
  final _pendingRead = <String>{};
  Timer? _saveTimer;
  late final int _initialIndex;

  /// Read once: `ref` must not be used from [dispose], where the final
  /// position is saved.
  late final UserRepository _user;
  bool _wakelock = false;

  ReaderOutline get o => widget.outline;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _user = ref.read(userRepositoryProvider);
    final t = widget.target;
    _initialIndex =
        (t.hadithId != null ? o.hadithIndex[t.hadithId] : null) ??
        (t.chapterId != null ? o.chapterIndex[t.chapterId] : null) ??
        0;
    _top.value = _initialIndex;
    _positions.itemPositions.addListener(_onPositions);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refineInitialScroll());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positions.itemPositions.removeListener(_onPositions);
    _saveTimer?.cancel();
    _save();
    if (_wakelock) WakelockPlus.disable();
    _top.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _saveTimer?.cancel();
      _save();
    }
  }

  void _syncWakelock(bool wanted) {
    if (wanted == _wakelock) return;
    _wakelock = wanted;
    wanted ? WakelockPlus.enable() : WakelockPlus.disable();
  }

  /// Restores a partially scrolled item (saved position) and, for search
  /// results inside long hadiths, brings the matched word into view.
  Future<void> _refineInitialScroll() async {
    final t = widget.target;
    var fraction = t.anchorOffset;
    if (t.highlight != null && t.hadithId != null) {
      final block = o.hadithIndex[t.hadithId]! - 0;
      final ordinal = (o.entries[block] as HadithEntry).ordinal;
      final loaded = await ref.read(
        hadithBlockProvider((bookId: o.book.id, block: ordinal ~/ ReaderOutline.blockSize)).future,
      );
      final text = loaded[t.hadithId]?.hadith.text ?? '';
      final nt = ArabicNormalizer.normalize(text, broad: t.highlight!.broad);
      final tokens = t.highlight!.tokens;
      final at = tokens.isEmpty ? -1 : nt.indexOf(tokens.first);
      if (at > 0 && nt.isNotEmpty) fraction = (at / nt.length) - 0.1;
    }
    if (fraction <= 0 || !mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final p = _positions.itemPositions.value.where((p) => p.index == _initialIndex).firstOrNull;
    if (p == null || !_items.isAttached) return;
    final height = p.itemTrailingEdge - p.itemLeadingEdge;
    if (height <= 0.5 && t.highlight != null) return; // short item: already fully visible
    _items.jumpTo(index: _initialIndex, alignment: -(fraction.clamp(0, 1)) * height);
  }

  void _onPositions() {
    final all = _positions.itemPositions.value;
    if (all.isEmpty) return;
    final visible = all.where((p) => p.itemTrailingEdge > 0.001).toList()..sort((a, b) => a.index.compareTo(b.index));
    if (visible.isEmpty) return;
    _top.value = visible.first.index;
    // A hadith the reader has scrolled completely past counts as read.
    for (final p in all) {
      if (p.itemTrailingEdge <= 0.02 && p.index < o.entries.length) {
        final e = o.entries[p.index];
        if (e is HadithEntry) _pendingRead.add(e.uid);
      }
    }
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 800), _save);
  }

  void _save() {
    final all = _positions.itemPositions.value;
    final user = _user;
    if (_pendingRead.isNotEmpty) {
      user.setRead(_pendingRead.toList(), read: true);
      _pendingRead.clear();
    }
    final visible = all.where((p) => p.itemTrailingEdge > 0.001).toList()..sort((a, b) => a.index.compareTo(b.index));
    if (visible.isEmpty) return;
    final top = visible.first;
    final entry = o.entries[top.index];
    final chapter = o.chapterAt(top.index);
    final height = top.itemTrailingEdge - top.itemLeadingEdge;
    final offset = height <= 0 ? 0.0 : (-top.itemLeadingEdge / height).clamp(0.0, 1.0);
    final hadithUid = switch (entry) {
      final HadithEntry e => e.uid,
      _ => null,
    };
    user.savePosition(
      bookUid: o.book.uid,
      chapterUid: entry is BookHeaderEntry ? null : chapter?.uid,
      hadithUid: hadithUid,
      anchorOffset: offset.toDouble(),
    );
    if (hadithUid != null) user.recordOpened(hadithUid);
  }

  void _jumpTo(int index) {
    if (!_items.isAttached) return;
    _items.scrollTo(
      index: index.clamp(0, o.entries.length - 1),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  int? _find(bool Function(ReaderEntry e) test, {required bool forward}) {
    final top = _top.value;
    final topPos = _positions.itemPositions.value.where((p) => p.index == top).firstOrNull;
    final partlyAbove = topPos != null && topPos.itemLeadingEdge < -0.01;
    if (forward) {
      for (var i = top + 1; i < o.entries.length; i++) {
        if (test(o.entries[i])) return i;
      }
    } else {
      if (partlyAbove && test(o.entries[top])) return top;
      for (var i = top - 1; i >= 0; i--) {
        if (test(o.entries[i])) return i;
      }
    }
    return null;
  }

  bool _isChapterStart(ReaderEntry e) => e is ChapterHeaderEntry || e is BookHeaderEntry;

  Future<void> _goBook(int delta) async {
    final books = await ref.read(booksProvider.future);
    final i = books.indexWhere((b) => b.id == o.book.id) + delta;
    if (i < 0 || i >= books.length || !mounted) return;
    context.pushReplacement(ReaderTarget(bookId: books[i].id).location);
  }

  Future<void> _jumpToNumber() async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.readerJumpToHadith),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: l10n.readerJumpHint),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: Text(l10n.readerJumpGo)),
        ],
      ),
    );
    controller.dispose();
    final n = int.tryParse(ArabicNormalizer.toWesternDigits(value?.trim() ?? ''));
    if (n == null || !mounted) return;
    final found = await ref.read(contentRepositoryProvider).hadithsByNumber(n);
    if (!mounted) return;
    if (found.isEmpty) {
      context.showSnack(l10n.readerHadithNotFound(context.number(n)));
      return;
    }
    final h = found.first;
    if (h.bookId == o.book.id) {
      _jumpTo(o.hadithIndex[h.id]!);
    } else {
      context.pushReplacement(ReaderTarget(bookId: h.bookId, hadithId: h.id).location);
    }
  }

  void _showContents() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (sheetContext, scroll) {
          final headers = [
            for (var i = 0; i < o.entries.length; i++)
              if (o.entries[i] is ChapterHeaderEntry || o.entries[i] is BookHeaderEntry) i,
          ];
          return Column(
            children: [
              ListTile(
                title: Text(context.l10n.readerTableOfContents, style: Theme.of(context).textTheme.titleMedium),
                trailing: TextButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    context.push('/books');
                  },
                  child: Text(context.l10n.booksTitle),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scroll,
                  itemCount: headers.length,
                  itemBuilder: (_, i) {
                    final e = o.entries[headers[i]];
                    final (text, depth) = switch (e) {
                      BookHeaderEntry b => (b.book.heading, 0),
                      ChapterHeaderEntry c => (c.chapter.heading ?? '', c.chapter.depth),
                      _ => ('', 0),
                    };
                    return ListTile(
                      contentPadding: EdgeInsetsDirectional.only(start: 16.0 + depth * 16, end: 16),
                      title: ArabicText(text, style: const TextStyle(fontFamily: 'Amiri', fontSize: 17, height: 1.6)),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _jumpTo(headers[i]);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    _syncWakelock(settings.keepAwake);
    final palette = ReaderPalette.resolve(settings.readerTheme, MediaQuery.platformBrightnessOf(context));
    final l10n = context.l10n;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final appBarTheme = Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme
          .copyWith(brightness: palette.brightness, surface: palette.background, onSurface: palette.text),
    );
    return Theme(
      data: appBarTheme,
      child: Scaffold(
        backgroundColor: palette.background,
        appBar: AppBar(
          backgroundColor: palette.background,
          foregroundColor: palette.text,
          title: Text(
            o.book.title,
            textDirection: TextDirection.rtl,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: 'Amiri', fontSize: 19, color: palette.heading, fontWeight: FontWeight.w700),
          ),
          actions: [
            IconButton(tooltip: l10n.readerTableOfContents, icon: const Icon(Icons.toc), onPressed: _showContents),
            IconButton(
              tooltip: l10n.readerJumpToHadith,
              icon: const Icon(Icons.pin_outlined),
              onPressed: _jumpToNumber,
            ),
            IconButton(
              tooltip: l10n.readerSettings,
              icon: const Icon(Icons.text_format),
              onPressed: () => showReaderSettings(context),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(34),
            child: ValueListenableBuilder<int>(
              valueListenable: _top,
              builder: (context, top, _) {
                final chapter = o.chapterAt(top);
                final text = chapter == null || chapter.isImplicit ? o.book.heading : (chapter.heading ?? '');
                return Container(
                  height: 34,
                  alignment: AlignmentDirectional.centerStart,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: palette.divider)),
                  ),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontFamily: 'Amiri', fontSize: 15, color: palette.muted),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ScrollablePositionedList.builder(
              itemScrollController: _items,
              itemPositionsListener: _positions,
              initialScrollIndex: _initialIndex,
              itemCount: o.entries.length,
              itemBuilder: (context, i) => _EntryView(
                outline: o,
                index: i,
                settings: settings,
                palette: palette,
                target: widget.target,
                onPreviousBook: () => _goBook(-1),
                onNextBook: () => _goBook(1),
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: palette.background,
          height: 60,
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                tooltip: l10n.readerPreviousChapter,
                color: palette.muted,
                icon: Icon(rtl ? Icons.keyboard_double_arrow_right : Icons.keyboard_double_arrow_left),
                onPressed: () {
                  final i = _find(_isChapterStart, forward: false);
                  if (i != null) _jumpTo(i);
                },
              ),
              IconButton(
                tooltip: l10n.readerPreviousHadith,
                color: palette.muted,
                icon: Icon(rtl ? Icons.chevron_right : Icons.chevron_left),
                onPressed: () {
                  final i = _find((e) => e is HadithEntry, forward: false);
                  i != null ? _jumpTo(i) : _goBook(-1);
                },
              ),
              IconButton(
                tooltip: l10n.readerNextHadith,
                color: palette.muted,
                icon: Icon(rtl ? Icons.chevron_left : Icons.chevron_right),
                onPressed: () {
                  final i = _find((e) => e is HadithEntry, forward: true);
                  i != null ? _jumpTo(i) : _goBook(1);
                },
              ),
              IconButton(
                tooltip: l10n.readerNextChapter,
                color: palette.muted,
                icon: Icon(rtl ? Icons.keyboard_double_arrow_left : Icons.keyboard_double_arrow_right),
                onPressed: () {
                  final i = _find(_isChapterStart, forward: true);
                  i != null ? _jumpTo(i) : _jumpTo(o.entries.length - 1);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryView extends ConsumerWidget {
  const _EntryView({
    required this.outline,
    required this.index,
    required this.settings,
    required this.palette,
    required this.target,
    required this.onPreviousBook,
    required this.onNextBook,
  });

  final ReaderOutline outline;
  final int index;
  final AppSettings settings;
  final ReaderPalette palette;
  final ReaderTarget target;
  final VoidCallback onPreviousBook;
  final VoidCallback onNextBook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pad = settings.pagePadding;
    final entry = outline.entries[index];
    final styles = readerTextStyles(settings, palette);
    Widget source(String text, FootnoteOwner owner, int id, {TextAlign align = TextAlign.justify, double scale = 1}) =>
        SourceText(
          text: text,
          styles: scale == 1 ? styles : readerTextStyles(settings, palette, scale: scale),
          markers: outline.notesOf(owner, id),
          showMarkers: settings.showFootnoteMarkers,
          textAlign: align,
        );

    switch (entry) {
      case BookHeaderEntry(:final book):
        return Padding(
          padding: EdgeInsets.fromLTRB(pad, 28, pad, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (book.preamble != null)
                source(book.preamble!, FootnoteOwner.bookPreamble, book.id, align: TextAlign.center),
              Semantics(
                header: true,
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: palette.heading, fontWeight: FontWeight.w700),
                  child: SourceText(
                    text: book.heading,
                    styles: readerTextStyles(settings, palette, scale: 1.35).let(
                      (s) => SourceTextStyles(
                        base: s.base.copyWith(color: palette.heading, fontWeight: FontWeight.w700),
                        emphasis: s.emphasis,
                        marker: s.marker,
                        highlight: s.highlight,
                      ),
                    ),
                    markers: _offsetMarkers(
                      outline.notesOf(FootnoteOwner.bookTitle, book.id),
                      book.heading,
                      book.title,
                    ),
                    showMarkers: settings.showFootnoteMarkers,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              if (book.intro != null) ...[
                const SizedBox(height: 12),
                source(book.intro!, FootnoteOwner.bookIntro, book.id),
              ],
              const SizedBox(height: 8),
              Divider(color: palette.divider),
            ],
          ),
        );
      case ChapterHeaderEntry(:final chapter):
        final headingStyles = readerTextStyles(settings, palette, scale: 1.12);
        return Padding(
          padding: EdgeInsets.fromLTRB(pad, 28, pad + (chapter.depth - 1) * 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Divider(color: palette.divider, height: 1),
              const SizedBox(height: 20),
              Semantics(
                header: true,
                child: SourceText(
                  text: chapter.heading ?? '',
                  styles: SourceTextStyles(
                    base: headingStyles.base.copyWith(color: palette.heading, fontWeight: FontWeight.w700),
                    emphasis: headingStyles.emphasis,
                    marker: headingStyles.marker,
                    highlight: headingStyles.highlight,
                  ),
                  markers: _offsetMarkers(
                    outline.notesOf(FootnoteOwner.chapterTitle, chapter.id),
                    chapter.heading ?? '',
                    chapter.title ?? '',
                  ),
                  showMarkers: settings.showFootnoteMarkers,
                  textAlign: TextAlign.center,
                ),
              ),
              if (chapter.intro != null) ...[
                const SizedBox(height: 10),
                source(chapter.intro!, FootnoteOwner.chapterIntro, chapter.id),
              ],
              if (chapter.hadithCount == 0 && chapter.intro == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    context.l10n.chapterNoHadiths,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'NotoSansArabic', fontSize: 13, color: palette.muted),
                  ),
                ),
            ],
          ),
        );
      case HadithEntry(:final hadithId, :final ordinal, :final chapterId):
        final block = ref.watch(
          hadithBlockProvider((bookId: outline.book.id, block: ordinal ~/ ReaderOutline.blockSize)),
        );
        return Padding(
          padding: EdgeInsets.fromLTRB(pad, 14, pad, 14),
          child: block.when(
            loading: () => const SizedBox(height: 160),
            error: (e, st) => ErrorView(
              onRetry: () => ref.invalidate(
                hadithBlockProvider((bookId: outline.book.id, block: ordinal ~/ ReaderOutline.blockSize)),
              ),
            ),
            data: (map) {
              final loaded = map[hadithId];
              if (loaded == null) return const SizedBox.shrink();
              return HadithView(
                hadith: loaded.hadith,
                footnotes: loaded.footnotes,
                book: outline.book,
                chapter: outline.chapters[chapterId],
                highlight: target.hadithId == hadithId ? target.highlight : null,
              );
            },
          ),
        );
      case BookEndEntry():
        return Padding(
          padding: EdgeInsets.fromLTRB(pad, 24, pad, 48),
          child: Column(
            children: [
              Divider(color: palette.divider),
              const SizedBox(height: 12),
              Text(
                context.l10n.readerEndOfBook,
                style: TextStyle(fontFamily: 'NotoSansArabic', color: palette.muted),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton(onPressed: onPreviousBook, child: Text(context.l10n.readerPreviousBook)),
                  FilledButton(onPressed: onNextBook, child: Text(context.l10n.readerNextBook)),
                ],
              ),
            ],
          ),
        );
    }
  }

  /// Footnote offsets of titles are relative to the title (number removed);
  /// the reader displays the full heading, so shift them.
  static List<FootnoteRef> _offsetMarkers(List<FootnoteRef> refs, String heading, String title) {
    final shift = heading.length - title.length;
    if (shift <= 0 || !heading.endsWith(title)) return refs;
    return [
      for (final r in refs)
        FootnoteRef(offset: r.offset + shift, marker: r.marker, footnoteId: r.footnoteId, footnoteText: r.footnoteText),
    ];
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T it) f) => f(this);
}
