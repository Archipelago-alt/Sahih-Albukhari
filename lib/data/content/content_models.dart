/// Read-only models of the canonical content database
/// (`assets/content/bukhari_taseel.db`, built by `tool/import/build_database.py`).
///
/// Text fields hold the untouched source text. Nothing in the app rewrites
/// them; search uses a separate normalized index.
library;

import 'dart:convert';

class Book {
  const Book({
    required this.id,
    required this.uid,
    required this.sortOrder,
    required this.number,
    required this.numberText,
    required this.title,
    required this.heading,
    required this.preamble,
    required this.intro,
    required this.volume,
    required this.printedPage,
    required this.chapterCount,
    required this.hadithCount,
    required this.firstHadithId,
    required this.lastHadithId,
  });

  final int id;
  final String uid;
  final int sortOrder;
  final int? number;
  final String? numberText;

  /// Book name without its number, exactly as printed.
  final String title;

  /// Full heading line as printed, e.g. "٢ - كِتَابُ الإيمَانِ".
  final String heading;

  /// Text printed before the heading (e.g. the basmala), if any.
  final String? preamble;

  /// Text between the book heading and its first chapter (al-Bukhari's
  /// introductory verses/reports), if any.
  final String? intro;
  final int? volume;
  final String? printedPage;
  final int chapterCount;
  final int hadithCount;
  final int? firstHadithId;
  final int? lastHadithId;
}

class Chapter {
  const Chapter({
    required this.id,
    required this.uid,
    required this.bookId,
    required this.parentId,
    required this.depth,
    required this.sortOrder,
    required this.isImplicit,
    required this.number,
    required this.numberText,
    required this.title,
    required this.heading,
    required this.intro,
    required this.volume,
    required this.printedPage,
    required this.hadithCount,
    required this.firstHadithId,
    required this.lastHadithId,
  });

  final int id;
  final String uid;
  final int bookId;
  final int? parentId;

  /// 1 = directly under the book; 2+ = nested under another chapter.
  final int depth;
  final int sortOrder;

  /// True for the container of hadiths that appear under a book with no
  /// chapter heading in the source. It has no title and is never labelled.
  final bool isImplicit;
  final int? number;
  final String? numberText;
  final String? title;
  final String? heading;

  /// Chapter text (tarjama) printed between the heading and the first hadith.
  final String? intro;
  final int? volume;
  final String? printedPage;
  final int hadithCount;
  final int? firstHadithId;
  final int? lastHadithId;
}

/// A styled range of a text, as marked in the source (e.g. bold matn).
class StyleSpan {
  const StyleSpan(this.style, this.start, this.end);

  final String style;
  final int start;
  final int end;

  static List<StyleSpan> decodeList(String json) => [
    for (final item in jsonDecode(json) as List<dynamic>)
      StyleSpan((item as List<dynamic>)[0] as String, item[1] as int, item[2] as int),
  ];
}

class Hadith {
  const Hadith({
    required this.id,
    required this.uid,
    required this.sortOrder,
    required this.bookId,
    required this.chapterId,
    required this.number,
    this.numberEnd,
    required this.numberText,
    required this.text,
    required this.spans,
    required this.volume,
    required this.printedPageStart,
    required this.printedPageEnd,
    required this.tuhfa,
  });

  final int id;

  /// Stable identifier used by bookmarks, notes and backups (e.g. "h16").
  final String uid;
  final int sortOrder;
  final int bookId;
  final int chapterId;
  final int? number;

  /// Second number when one record is printed under two, e.g. [٤١٢ - ٤١٣].
  final int? numberEnd;

  /// The hadith number exactly as printed, e.g. "١٦".
  final String numberText;

  /// Canonical hadith text (editor footnote markers held separately).
  final String text;
  final List<StyleSpan> spans;
  final int? volume;
  final String? printedPageStart;
  final String? printedPageEnd;

  /// The editor's Tuhfat al-Ashraf reference line(s), if any.
  final String? tuhfa;
}

/// Which text a footnote marker belongs to.
enum FootnoteOwner {
  bookTitle('book_title'),
  bookPreamble('book_preamble'),
  bookIntro('book_intro'),
  chapterTitle('chapter_title'),
  chapterIntro('chapter_intro'),
  hadith('hadith');

  const FootnoteOwner(this.column);
  final String column;
}

/// An editor footnote marker positioned inside a canonical text, with the
/// footnote it refers to.
class FootnoteRef {
  const FootnoteRef({required this.offset, required this.marker, required this.footnoteId, required this.footnoteText});

  /// Character offset in the owner text where the marker is printed.
  final int offset;

  /// The marker as printed, e.g. "(٣)".
  final String marker;
  final int? footnoteId;
  final String? footnoteText;
}

/// Metadata of the installed content database.
class ContentInfo {
  const ContentInfo(this.values);

  final Map<String, String> values;

  String? get sourceUrl => values['source_url'];
  String? get sourceContentSha256 => values['source_content_sha256'];
  String? get importerVersion => values['importer_version'];
  String? get builtAt => values['built_at'];

  Map<String, String> get sourceCard {
    final raw = values['source_card'];
    if (raw == null) return const {};
    return (jsonDecode(raw) as Map<String, dynamic>).map((k, v) => MapEntry(k, v as String));
  }
}
