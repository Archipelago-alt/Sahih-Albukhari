// End-to-end flow on a device/emulator (or desktop):
//   flutter test integration_test/app_flow_test.dart
//
// Uses the real bundled content database and real text from the source:
// book 2 (كتاب الإيمان), chapter 9 (بَابُ حَلَاوَةِ الْإِيمَانِ), hadith [١٦].
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sahih_albukhari/features/reader/hadith_view.dart';
import 'package:sahih_albukhari/main.dart';

const bookTitle = 'كِتَابُ الإيمَانِ';
const chapterHeading = '٩ - بَابُ حَلَاوَةِ الْإِيمَانِ';
const hadithLabel = 'حديث رقم ١٦';
const hadithOpening = 'حدثنا مُحَمَّدُ بْنُ';
const noteText = 'ملاحظة اختبار التكامل';

Future<void> settle(WidgetTester tester, [int seconds = 2]) async {
  for (var i = 0; i < seconds * 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// The screen's main list; screens also contain other scrollables (text
/// fields), so scrolling must name the one to drag.
Finder listScrollable(Type list) => find.descendant(of: find.byType(list), matching: find.byType(Scrollable)).first;

/// Taps the app bar's back button. `tester.pageBack()` looks for the
/// English "Back" tooltip, which the Arabic interface does not have.
Future<void> goBack(WidgetTester tester) => tester.tap(find.byType(BackButton).first);

Finder hadith16() => find.ancestor(of: find.text(hadithLabel), matching: find.byType(HadithView));

/// The source text shown by a [SelectableText] (any tappable spans excluded).
String sourceTextOf(SelectableText w) {
  final out = StringBuffer();
  w.textSpan?.visitChildren((s) {
    if (s is TextSpan && s.recognizer == null) out.write(s.text ?? '');
    return true;
  });
  return out.toString();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('browse, bookmark, note, search, restart', (tester) async {
    await tester.pumpWidget(const Bootstrap());
    await settle(tester, 6);

    // 1–2. Open the books list and book 2.
    await tester.tap(find.text('الكتب').first);
    await settle(tester);
    await tester.scrollUntilVisible(find.text(bookTitle), 200, scrollable: listScrollable(ListView));
    await tester.tap(find.text(bookTitle));
    await settle(tester);

    // 3–4. Open chapter 9 and confirm its original name.
    await tester.scrollUntilVisible(find.text(chapterHeading), 200, scrollable: listScrollable(CustomScrollView));
    expect(find.text(chapterHeading), findsOneWidget);
    await tester.tap(find.text(chapterHeading));
    await settle(tester, 3);

    // 5. The chapter heading is shown, with hadith 16 beneath it.
    expect(find.textContaining('حَلَاوَةِ الْإِيمَانِ'), findsWidgets);
    expect(hadith16(), findsOneWidget);
    final headingY = tester
        .getTopLeft(
          find.byWidgetPredicate((w) => w is SelectableText && sourceTextOf(w).startsWith(chapterHeading)).first,
        )
        .dy;
    expect(tester.getTopLeft(hadith16()).dy, greaterThan(headingY));
    expect(
      find.descendant(of: hadith16(), matching: find.textContaining(hadithOpening, findRichText: true)),
      findsOneWidget,
    );

    // 6. Bookmark it.
    await tester.tap(find.descendant(of: hadith16(), matching: find.byTooltip('المزيد')));
    await settle(tester);
    await tester.tap(find.text('إضافة علامة'));
    await settle(tester);

    // 7. Add a private note.
    await tester.tap(find.descendant(of: hadith16(), matching: find.byTooltip('المزيد')));
    await settle(tester);
    await tester.tap(find.text('إضافة ملاحظة'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).last, noteText);
    await tester.tap(find.text('حفظ'));
    await settle(tester);
    expect(find.text(noteText), findsOneWidget);

    // 8–9. Search a verified phrase and open the result in its chapter.
    await goBack(tester);
    await settle(tester);
    await goBack(tester);
    await settle(tester);
    await goBack(tester);
    await settle(tester);
    await tester.tap(find.text('البحث').first);
    await settle(tester);
    await tester.tap(find.text('عبارة متصلة'));
    await tester.enterText(find.byType(TextField).first, 'ثلاث من كن فيه وجد حلاوة الايمان');
    await settle(tester, 3);
    expect(find.text(hadithLabel), findsWidgets);
    await tester.tap(find.text(hadithLabel).first);
    await settle(tester, 3);
    expect(hadith16(), findsOneWidget);
    // The reader's chapter indicator names the correct chapter.
    expect(find.text(chapterHeading), findsWidgets);
    await settle(tester, 2); // let the position be saved

    // 10. Restart the app.
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    await tester.pumpWidget(const Bootstrap());
    await settle(tester, 6);

    // 11. Bookmark, note and reading position persist.
    expect(find.text('متابعة القراءة'), findsOneWidget);
    expect(find.text(hadithLabel), findsWidgets);
    await tester.tap(find.text('العلامات').first);
    await settle(tester);
    expect(find.textContaining(hadithLabel), findsOneWidget);
    await goBack(tester);
    await settle(tester);
    await tester.tap(find.text('ملاحظاتي').first);
    await settle(tester);
    expect(find.text(noteText), findsOneWidget);
  });
}
