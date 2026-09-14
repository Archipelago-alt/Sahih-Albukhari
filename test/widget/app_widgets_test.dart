import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahih_albukhari/app/theme.dart';
import 'package:sahih_albukhari/core/arabic/arabic_normalizer.dart';
import 'package:sahih_albukhari/data/user/user_repository.dart';
import 'package:sahih_albukhari/features/reader/hadith_view.dart';
import 'package:sahih_albukhari/features/settings/app_settings.dart';
import 'package:sahih_albukhari/l10n/gen/app_localizations.dart';
import 'package:sahih_albukhari/shared/state_views.dart';

import '../helpers/harness.dart';

const hadith16 = 'حديث رقم ١٦';

/// Headings of book 2, chapters 9 and 10, read from the generated database
/// (never hand-typed, so the test compares against the source exactly).
class Book2 {
  Book2(this.title, this.chapter9Id, this.chapter9, this.chapter10);
  final String title;
  final int chapter9Id;
  final String chapter9;
  final String chapter10;
}

Future<Book2> loadBook2(WidgetTester tester, TestDbs dbs) async {
  return (await tester.runAsync(() async {
    final title = (await dbs.content.customSelect('SELECT title FROM books WHERE number = 2').getSingle()).read<String>(
      'title',
    );
    final rows = await dbs.content
        .customSelect(
          'SELECT c.id, c.number, c.heading FROM chapters c JOIN books b ON b.id = c.book_id '
          'WHERE b.number = 2 AND c.number IN (9, 10) AND c.is_implicit = 0 ORDER BY c.sort_order',
        )
        .get();
    final c9 = rows.firstWhere((r) => r.read<int>('number') == 9);
    final c10 = rows.firstWhere((r) => r.read<int>('number') == 10);
    return Book2(title, c9.read<int>('id'), c9.read<String>('heading'), c10.read<String>('heading'));
  }))!;
}

// List items built in the cache area outside the viewport count as
// offstage, so position checks look past that.
/// The source text shown by a [SelectableText] (any tappable spans excluded).
String sourceTextOf(SelectableText w) {
  final out = StringBuffer();
  w.textSpan?.visitChildren((s) {
    if (s is TextSpan && s.recognizer == null) out.write(s.text ?? '');
    return true;
  });
  return out.toString();
}

Finder sourceTextStartingWith(String prefix) =>
    find.byWidgetPredicate((w) => w is SelectableText && sourceTextOf(w).startsWith(prefix), skipOffstage: false);

Finder mainScrollable() => find.descendant(of: find.byType(CustomScrollView), matching: find.byType(Scrollable)).first;

void main() {
  final skip = !contentAvailable;

  testWidgets('home is right-to-left in Arabic and titled صحيح البخاري', (tester) async {
    final dbs = TestDbs();
    await tester.pumpWidget(testApp(dbs));
    await settle(tester);
    expect(find.text('صحيح البخاري'), findsWidgets);
    expect(Directionality.of(tester.element(find.text('الكتب').first)), TextDirection.rtl);
    await tearDownApp(tester, dbs);
  }, skip: skip);

  testWidgets('English UI is left-to-right but source text stays RTL', (tester) async {
    final dbs = TestDbs();
    final book2 = await loadBook2(tester, dbs);
    await tester.pumpWidget(
      testApp(
        dbs,
        location: '/books',
        settings: const AppSettings(language: AppLanguage.en),
      ),
    );
    await settle(tester);
    expect(Directionality.of(tester.element(find.text('Books').first)), TextDirection.ltr);
    final title = tester.widget<Text>(
      find.descendant(of: find.widgetWithText(ArabicText, book2.title), matching: find.byType(Text)),
    );
    expect(title.textDirection, TextDirection.rtl);
    await tearDownApp(tester, dbs);
  }, skip: skip);

  testWidgets('chapters screen shows the original Arabic headings in order', (tester) async {
    final dbs = TestDbs();
    final book2 = await loadBook2(tester, dbs);
    await tester.pumpWidget(testApp(dbs, location: '/books/2'));
    await settle(tester);
    await tester.scrollUntilVisible(find.text(book2.chapter9), 200, scrollable: mainScrollable());
    await settle(tester, frames: 5);
    final c9 = find.text(book2.chapter9, skipOffstage: false);
    final c10 = find.text(book2.chapter10, skipOffstage: false);
    expect(c9, findsOneWidget);
    expect(c10, findsOneWidget);
    expect(tester.getTopLeft(c9).dy, lessThan(tester.getTopLeft(c10).dy));
    await tearDownApp(tester, dbs);
  }, skip: skip);

  testWidgets('reader shows hadith 16 beneath chapter 9 and before chapter 10', (tester) async {
    final dbs = TestDbs();
    final book2 = await loadBook2(tester, dbs);
    await tester.pumpWidget(testApp(dbs, location: '/read/2?chapter=${book2.chapter9Id}'));
    await settle(tester, frames: 40);
    final heading = sourceTextStartingWith(book2.chapter9);
    final hadith = find.ancestor(of: find.text(hadith16, skipOffstage: false), matching: find.byType(HadithView));
    expect(heading, findsOneWidget);
    expect(hadith, findsOneWidget);
    expect(tester.getTopLeft(hadith).dy, greaterThan(tester.getTopLeft(heading).dy));
    final next = sourceTextStartingWith(book2.chapter10);
    if (next.evaluate().isNotEmpty) {
      expect(tester.getTopLeft(next).dy, greaterThan(tester.getTopLeft(hadith).dy));
    }
    await tearDownApp(tester, dbs);
  }, skip: skip);

  testWidgets('reader settings change the reading font size', (tester) async {
    final dbs = TestDbs();
    await tester.pumpWidget(testApp(dbs, location: '/read/2', settings: const AppSettings(fontSize: 30)));
    await settle(tester, frames: 40);
    final sizes = <double?>{};
    for (final w in tester.widgetList<SelectableText>(find.byType(SelectableText))) {
      w.textSpan?.visitChildren((s) {
        if (s is TextSpan && (s.text ?? '').isNotEmpty) sizes.add(s.style?.fontSize);
        return true;
      });
    }
    expect(sizes, contains(30.0), reason: 'body text uses the chosen size');
    expect(sizes, contains(closeTo(30 * 1.35, 0.01)), reason: 'book heading is scaled from it');
    await tearDownApp(tester, dbs);
  }, skip: skip);

  testWidgets('search shows a result count and highlights matches', (tester) async {
    final dbs = TestDbs();
    await tester.pumpWidget(testApp(dbs, location: '/search'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).first, 'حلاوة الايمان');
    await settle(tester, frames: 60);
    expect(find.textContaining('في الأحاديث'), findsOneWidget);
    expect(find.text(hadith16), findsWidgets);
    final highlighted = find.byWidgetPredicate((w) {
      if (w is! RichText) return false;
      var found = false;
      w.text.visitChildren((s) {
        if (s is TextSpan &&
            s.style?.backgroundColor != null &&
            ArabicNormalizer.normalize(s.text ?? '').contains('حلاوة')) {
          found = true;
        }
        return !found;
      });
      return found;
    });
    expect(highlighted, findsWidgets);
    await tearDownApp(tester, dbs);
  }, skip: skip);

  testWidgets('bookmarking a hadith updates the bookmarks screen', (tester) async {
    final dbs = TestDbs();
    await tester.runAsync(() => UserRepository(dbs.user).addBookmark('h16', label: 'اختبار'));
    await tester.pumpWidget(testApp(dbs, location: '/bookmarks'));
    await settle(tester, frames: 40);
    expect(find.textContaining(hadith16), findsOneWidget);
    await tester.tap(find.byType(PopupMenuButton<String>).first);
    await settle(tester);
    await tester.tap(find.text('إزالة العلامة').last);
    await settle(tester, frames: 40);
    expect(find.text('لا توجد علامات بعد'), findsOneWidget);
    await tearDownApp(tester, dbs);
  }, skip: skip);

  testWidgets('empty states for notes and bookmarks', (tester) async {
    final dbs = TestDbs();
    await tester.pumpWidget(testApp(dbs, location: '/notes'));
    await settle(tester);
    expect(find.text('لا توجد ملاحظات بعد'), findsOneWidget);
    await tearDownApp(tester, dbs);
  }, skip: skip);

  testWidgets('error view explains the problem and offers a retry', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(body: ErrorView(onRetry: () => retried = true)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('حدث خطأ'), findsOneWidget);
    await tester.tap(find.text('إعادة المحاولة'));
    expect(retried, isTrue);
  });

  testWidgets('large accessibility text scale renders without overflow', (tester) async {
    final dbs = TestDbs();
    await tester.pumpWidget(testApp(dbs, textScale: 2.0));
    await settle(tester);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(testApp(dbs, location: '/read/2', textScale: 2.0));
    await settle(tester, frames: 40);
    expect(tester.takeException(), isNull);
    await tearDownApp(tester, dbs);
  }, skip: skip);
}
