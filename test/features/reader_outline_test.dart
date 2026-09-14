import 'package:flutter_test/flutter_test.dart';
import 'package:sahih_albukhari/data/content/content_models.dart';
import 'package:sahih_albukhari/features/reader/reader_outline.dart';

Book book({int id = 1}) => Book(
  id: id,
  uid: 'b$id',
  sortOrder: id,
  number: id,
  numberText: '$id',
  title: 't',
  heading: 'h',
  preamble: null,
  intro: null,
  volume: 1,
  printedPage: '1',
  chapterCount: 0,
  hadithCount: 0,
  firstHadithId: null,
  lastHadithId: null,
);

Chapter chapter(int id, int sort, {bool implicit = false, int? parent, int depth = 1}) => Chapter(
  id: id,
  uid: 'c$id',
  bookId: 1,
  parentId: parent,
  depth: depth,
  sortOrder: sort,
  isImplicit: implicit,
  number: id,
  numberText: '$id',
  title: implicit ? null : 'باب $id',
  heading: implicit ? null : '$id - باب $id',
  intro: null,
  volume: 1,
  printedPage: '1',
  hadithCount: 0,
  firstHadithId: null,
  lastHadithId: null,
);

void main() {
  test('hadiths appear directly beneath their own chapter, in order', () {
    final o = ReaderOutline.build(
      book: book(),
      chapters: [chapter(11, 2), chapter(10, 1), chapter(12, 3)],
      hadiths: [
        (id: 1, uid: 'h1', chapterId: 10),
        (id: 2, uid: 'h2', chapterId: 10),
        (id: 3, uid: 'h3', chapterId: 12),
      ],
    );
    final kinds = [
      for (final e in o.entries)
        switch (e) {
          BookHeaderEntry() => 'B',
          ChapterHeaderEntry(:final chapter) => 'C${chapter.id}',
          HadithEntry(:final hadithId) => 'H$hadithId',
          BookEndEntry() => 'E',
        },
    ];
    // Chapter 11 has no hadith but keeps its place between 10 and 12.
    expect(kinds, ['B', 'C10', 'H1', 'H2', 'C11', 'C12', 'H3', 'E']);
    expect(o.chapterAt(o.hadithIndex[3]!)!.id, 12);
    expect(o.chapterAt(0), isNull);
    expect(o.hadithIds, [1, 2, 3]);
  });

  test('implicit chapter shows its hadiths without a heading', () {
    final o = ReaderOutline.build(
      book: book(),
      chapters: [chapter(1, 1, implicit: true)],
      hadiths: [(id: 1, uid: 'h1', chapterId: 1), (id: 2, uid: 'h2', chapterId: 1)],
    );
    expect(o.entries.whereType<ChapterHeaderEntry>(), isEmpty);
    expect(o.entries.whereType<HadithEntry>().map((e) => e.ordinal), [0, 1]);
  });

  test('a hadith whose chapter is missing is an error, never guessed', () {
    expect(
      () => ReaderOutline.build(book: book(), chapters: [chapter(1, 1)], hadiths: [(id: 1, uid: 'h1', chapterId: 99)]),
      throwsStateError,
    );
  });
}
