import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ar'), Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'صحيح البخاري'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الجامع المسند الصحيح'**
  String get appSubtitle;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In ar, this message translates to:
  /// **'حسنًا'**
  String get ok;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @clear.
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get clear;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل…'**
  String get loading;

  /// No description provided for @errorTitle.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get errorTitle;

  /// No description provided for @errorBody.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إكمال العملية. حاول مرة أخرى.'**
  String get errorBody;

  /// No description provided for @contentInstallError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تجهيز نص الكتاب على هذا الجهاز. قد يكون ملف التطبيق تالفًا؛ أعد تثبيته.'**
  String get contentInstallError;

  /// No description provided for @homeContinueReading.
  ///
  /// In ar, this message translates to:
  /// **'متابعة القراءة'**
  String get homeContinueReading;

  /// No description provided for @homeStartReading.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ القراءة'**
  String get homeStartReading;

  /// No description provided for @homeStartReadingHint.
  ///
  /// In ar, this message translates to:
  /// **'من أول الكتاب: بدء الوحي'**
  String get homeStartReadingHint;

  /// No description provided for @homeLastRead.
  ///
  /// In ar, this message translates to:
  /// **'آخر ما قرأت'**
  String get homeLastRead;

  /// No description provided for @homeOverallProgress.
  ///
  /// In ar, this message translates to:
  /// **'التقدم في القراءة'**
  String get homeOverallProgress;

  /// No description provided for @homeProgressDetail.
  ///
  /// In ar, this message translates to:
  /// **'قرأت {read} من {total}'**
  String homeProgressDetail(String read, String total);

  /// No description provided for @homeProgressNone.
  ///
  /// In ar, this message translates to:
  /// **'لم تُعلَّم أي أحاديث كمقروءة بعد'**
  String get homeProgressNone;

  /// No description provided for @homeBrowseBooks.
  ///
  /// In ar, this message translates to:
  /// **'الكتب'**
  String get homeBrowseBooks;

  /// No description provided for @homeSearch.
  ///
  /// In ar, this message translates to:
  /// **'البحث'**
  String get homeSearch;

  /// No description provided for @homeBookmarks.
  ///
  /// In ar, this message translates to:
  /// **'العلامات'**
  String get homeBookmarks;

  /// No description provided for @homeNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظاتي'**
  String get homeNotes;

  /// No description provided for @homeRecent.
  ///
  /// In ar, this message translates to:
  /// **'قُرئ مؤخرًا'**
  String get homeRecent;

  /// No description provided for @homeRecentEmpty.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر هنا الأحاديث التي فتحتها مؤخرًا'**
  String get homeRecentEmpty;

  /// No description provided for @homeSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get homeSettings;

  /// No description provided for @booksTitle.
  ///
  /// In ar, this message translates to:
  /// **'الكتب'**
  String get booksTitle;

  /// No description provided for @booksFilterHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في أسماء الكتب'**
  String get booksFilterHint;

  /// No description provided for @booksNoMatch.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد كتاب بهذا الاسم'**
  String get booksNoMatch;

  /// No description provided for @bookChapters.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{بلا أبواب} =1{باب واحد} =2{بابان} few{{countText} أبواب} many{{countText} بابًا} other{{countText} باب}}'**
  String bookChapters(int count, String countText);

  /// No description provided for @bookHadiths.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{بلا أحاديث} =1{حديث واحد} =2{حديثان} few{{countText} أحاديث} many{{countText} حديثًا} other{{countText} حديث}}'**
  String bookHadiths(int count, String countText);

  /// No description provided for @percentRead.
  ///
  /// In ar, this message translates to:
  /// **'قُرئ {percent}٪'**
  String percentRead(String percent);

  /// No description provided for @chaptersFilterHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في أسماء الأبواب'**
  String get chaptersFilterHint;

  /// No description provided for @chaptersNoMatch.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد باب بهذا الاسم'**
  String get chaptersNoMatch;

  /// No description provided for @chaptersExpandAll.
  ///
  /// In ar, this message translates to:
  /// **'توسيع الكل'**
  String get chaptersExpandAll;

  /// No description provided for @chaptersCollapseAll.
  ///
  /// In ar, this message translates to:
  /// **'طي الكل'**
  String get chaptersCollapseAll;

  /// No description provided for @chapterNoHadiths.
  ///
  /// In ar, this message translates to:
  /// **'لا حديث تحت هذا الباب في الأصل'**
  String get chapterNoHadiths;

  /// No description provided for @chapterMarkRead.
  ///
  /// In ar, this message translates to:
  /// **'تعليم الباب كمقروء'**
  String get chapterMarkRead;

  /// No description provided for @chapterMarkUnread.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء تعليم الباب'**
  String get chapterMarkUnread;

  /// No description provided for @chapterOpen.
  ///
  /// In ar, this message translates to:
  /// **'افتح الباب'**
  String get chapterOpen;

  /// No description provided for @bookIntroLabel.
  ///
  /// In ar, this message translates to:
  /// **'مقدمة الكتاب'**
  String get bookIntroLabel;

  /// No description provided for @readWholeBook.
  ///
  /// In ar, this message translates to:
  /// **'اقرأ الكتاب من أوله'**
  String get readWholeBook;

  /// No description provided for @readerTableOfContents.
  ///
  /// In ar, this message translates to:
  /// **'الفهرس'**
  String get readerTableOfContents;

  /// No description provided for @readerJumpToHadith.
  ///
  /// In ar, this message translates to:
  /// **'انتقل إلى حديث'**
  String get readerJumpToHadith;

  /// No description provided for @readerJumpHint.
  ///
  /// In ar, this message translates to:
  /// **'رقم الحديث'**
  String get readerJumpHint;

  /// No description provided for @readerJumpGo.
  ///
  /// In ar, this message translates to:
  /// **'انتقال'**
  String get readerJumpGo;

  /// No description provided for @readerHadithNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد حديث برقم {number}'**
  String readerHadithNotFound(String number);

  /// No description provided for @readerPreviousHadith.
  ///
  /// In ar, this message translates to:
  /// **'الحديث السابق'**
  String get readerPreviousHadith;

  /// No description provided for @readerNextHadith.
  ///
  /// In ar, this message translates to:
  /// **'الحديث التالي'**
  String get readerNextHadith;

  /// No description provided for @readerPreviousChapter.
  ///
  /// In ar, this message translates to:
  /// **'الباب السابق'**
  String get readerPreviousChapter;

  /// No description provided for @readerNextChapter.
  ///
  /// In ar, this message translates to:
  /// **'الباب التالي'**
  String get readerNextChapter;

  /// No description provided for @readerSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات القراءة'**
  String get readerSettings;

  /// No description provided for @readerBookmark.
  ///
  /// In ar, this message translates to:
  /// **'إضافة علامة'**
  String get readerBookmark;

  /// No description provided for @readerRemoveBookmark.
  ///
  /// In ar, this message translates to:
  /// **'إزالة العلامة'**
  String get readerRemoveBookmark;

  /// No description provided for @readerAddNote.
  ///
  /// In ar, this message translates to:
  /// **'إضافة ملاحظة'**
  String get readerAddNote;

  /// No description provided for @readerEditNote.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملاحظة'**
  String get readerEditNote;

  /// No description provided for @readerCopy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ الحديث'**
  String get readerCopy;

  /// No description provided for @readerShare.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get readerShare;

  /// No description provided for @readerMarkRead.
  ///
  /// In ar, this message translates to:
  /// **'تعليم كمقروء'**
  String get readerMarkRead;

  /// No description provided for @readerMarkUnread.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء تعليم القراءة'**
  String get readerMarkUnread;

  /// No description provided for @readerCopied.
  ///
  /// In ar, this message translates to:
  /// **'نُسخ الحديث'**
  String get readerCopied;

  /// No description provided for @readerMore.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get readerMore;

  /// No description provided for @readerEndOfBook.
  ///
  /// In ar, this message translates to:
  /// **'نهاية الكتاب'**
  String get readerEndOfBook;

  /// No description provided for @readerNextBook.
  ///
  /// In ar, this message translates to:
  /// **'الكتاب التالي'**
  String get readerNextBook;

  /// No description provided for @readerPreviousBook.
  ///
  /// In ar, this message translates to:
  /// **'الكتاب السابق'**
  String get readerPreviousBook;

  /// No description provided for @readerRead.
  ///
  /// In ar, this message translates to:
  /// **'مقروء'**
  String get readerRead;

  /// No description provided for @hadithNumberLabel.
  ///
  /// In ar, this message translates to:
  /// **'حديث رقم {number}'**
  String hadithNumberLabel(String number);

  /// No description provided for @pageReference.
  ///
  /// In ar, this message translates to:
  /// **'ج{volume} ص{page}'**
  String pageReference(String volume, String page);

  /// No description provided for @shareReference.
  ///
  /// In ar, this message translates to:
  /// **'صحيح البخاري، {book}، {chapter}، حديث رقم {number} ({page}). ط. دار التأصيل، نص المكتبة الشاملة.'**
  String shareReference(String book, String chapter, String number, String page);

  /// No description provided for @shareReferenceNoChapter.
  ///
  /// In ar, this message translates to:
  /// **'صحيح البخاري، {book}، حديث رقم {number} ({page}). ط. دار التأصيل، نص المكتبة الشاملة.'**
  String shareReferenceNoChapter(String book, String number, String page);

  /// No description provided for @tuhfaLabel.
  ///
  /// In ar, this message translates to:
  /// **'تحفة الأشراف'**
  String get tuhfaLabel;

  /// No description provided for @showTuhfa.
  ///
  /// In ar, this message translates to:
  /// **'عرض مرجع تحفة الأشراف'**
  String get showTuhfa;

  /// No description provided for @hideTuhfa.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء مرجع تحفة الأشراف'**
  String get hideTuhfa;

  /// No description provided for @tuhfaDisclaimer.
  ///
  /// In ar, this message translates to:
  /// **'رقم تحفة الأشراف من إضافة محقق الطبعة، وليس من نص صحيح البخاري.'**
  String get tuhfaDisclaimer;

  /// No description provided for @readerCopyWithTuhfa.
  ///
  /// In ar, this message translates to:
  /// **'نسخ مع مرجع تحفة الأشراف'**
  String get readerCopyWithTuhfa;

  /// No description provided for @settingsFontSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم الخط'**
  String get settingsFontSize;

  /// No description provided for @settingsLineHeight.
  ///
  /// In ar, this message translates to:
  /// **'تباعد الأسطر'**
  String get settingsLineHeight;

  /// No description provided for @settingsPagePadding.
  ///
  /// In ar, this message translates to:
  /// **'هوامش الصفحة'**
  String get settingsPagePadding;

  /// No description provided for @settingsReaderTheme.
  ///
  /// In ar, this message translates to:
  /// **'مظهر القراءة'**
  String get settingsReaderTheme;

  /// No description provided for @readerThemeSystem.
  ///
  /// In ar, this message translates to:
  /// **'حسب النظام'**
  String get readerThemeSystem;

  /// No description provided for @readerThemeLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get readerThemeLight;

  /// No description provided for @readerThemeSepia.
  ///
  /// In ar, this message translates to:
  /// **'بني فاتح'**
  String get readerThemeSepia;

  /// No description provided for @readerThemeDark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get readerThemeDark;

  /// No description provided for @settingsReadingFont.
  ///
  /// In ar, this message translates to:
  /// **'خط القراءة'**
  String get settingsReadingFont;

  /// No description provided for @fontAmiri.
  ///
  /// In ar, this message translates to:
  /// **'أميري'**
  String get fontAmiri;

  /// No description provided for @fontNotoNaskh.
  ///
  /// In ar, this message translates to:
  /// **'نوتو نسخ'**
  String get fontNotoNaskh;

  /// No description provided for @settingsKeepAwake.
  ///
  /// In ar, this message translates to:
  /// **'إبقاء الشاشة مضاءة أثناء القراءة'**
  String get settingsKeepAwake;

  /// No description provided for @searchTitle.
  ///
  /// In ar, this message translates to:
  /// **'البحث'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن كلمة أو عبارة أو رقم حديث'**
  String get searchHint;

  /// No description provided for @searchModeAllWords.
  ///
  /// In ar, this message translates to:
  /// **'كل الكلمات'**
  String get searchModeAllWords;

  /// No description provided for @searchModePhrase.
  ///
  /// In ar, this message translates to:
  /// **'عبارة متصلة'**
  String get searchModePhrase;

  /// No description provided for @searchModeExact.
  ///
  /// In ar, this message translates to:
  /// **'مطابق بالتشكيل'**
  String get searchModeExact;

  /// No description provided for @searchWholeWords.
  ///
  /// In ar, this message translates to:
  /// **'كلمات كاملة فقط'**
  String get searchWholeWords;

  /// No description provided for @searchBroad.
  ///
  /// In ar, this message translates to:
  /// **'التسوية بين ة و ه'**
  String get searchBroad;

  /// No description provided for @searchFilterBook.
  ///
  /// In ar, this message translates to:
  /// **'الكتاب'**
  String get searchFilterBook;

  /// No description provided for @searchFilterChapter.
  ///
  /// In ar, this message translates to:
  /// **'الباب'**
  String get searchFilterChapter;

  /// No description provided for @searchAnyBook.
  ///
  /// In ar, this message translates to:
  /// **'كل الكتب'**
  String get searchAnyBook;

  /// No description provided for @searchAnyChapter.
  ///
  /// In ar, this message translates to:
  /// **'كل الأبواب'**
  String get searchAnyChapter;

  /// No description provided for @searchResultCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا نتائج} =1{نتيجة واحدة} =2{نتيجتان} few{{countText} نتائج} many{{countText} نتيجة} other{{countText} نتيجة}}'**
  String searchResultCount(int count, String countText);

  /// No description provided for @searchHeadingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'في أسماء الكتب والأبواب'**
  String get searchHeadingsTitle;

  /// No description provided for @searchHadithsTitle.
  ///
  /// In ar, this message translates to:
  /// **'في الأحاديث'**
  String get searchHadithsTitle;

  /// No description provided for @searchNumberTitle.
  ///
  /// In ar, this message translates to:
  /// **'بالرقم'**
  String get searchNumberTitle;

  /// No description provided for @searchNoResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get searchNoResults;

  /// No description provided for @searchNoResultsHint.
  ///
  /// In ar, this message translates to:
  /// **'جرّب كلمات أقل، أو ألغِ خيار «كلمات كاملة فقط»، أو فعّل التسوية بين ة و ه.'**
  String get searchNoResultsHint;

  /// No description provided for @searchRecent.
  ///
  /// In ar, this message translates to:
  /// **'عمليات البحث الأخيرة'**
  String get searchRecent;

  /// No description provided for @searchClearHistory.
  ///
  /// In ar, this message translates to:
  /// **'مسح سجل البحث'**
  String get searchClearHistory;

  /// No description provided for @searchStartHint.
  ///
  /// In ar, this message translates to:
  /// **'يعمل البحث دون اتصال. لا تؤثر التسوية بين الحروف على النص المعروض.'**
  String get searchStartHint;

  /// No description provided for @searchOptions.
  ///
  /// In ar, this message translates to:
  /// **'خيارات البحث'**
  String get searchOptions;

  /// No description provided for @bookmarksTitle.
  ///
  /// In ar, this message translates to:
  /// **'العلامات'**
  String get bookmarksTitle;

  /// No description provided for @bookmarksEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد علامات بعد'**
  String get bookmarksEmpty;

  /// No description provided for @bookmarksEmptyHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف علامة من قائمة أي حديث أثناء القراءة.'**
  String get bookmarksEmptyHint;

  /// No description provided for @bookmarksAllFolders.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get bookmarksAllFolders;

  /// No description provided for @bookmarksNoFolder.
  ///
  /// In ar, this message translates to:
  /// **'بلا مجلد'**
  String get bookmarksNoFolder;

  /// No description provided for @bookmarksNewFolder.
  ///
  /// In ar, this message translates to:
  /// **'مجلد جديد'**
  String get bookmarksNewFolder;

  /// No description provided for @bookmarksFolderName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المجلد'**
  String get bookmarksFolderName;

  /// No description provided for @bookmarksRenameFolder.
  ///
  /// In ar, this message translates to:
  /// **'إعادة التسمية'**
  String get bookmarksRenameFolder;

  /// No description provided for @bookmarksDeleteFolder.
  ///
  /// In ar, this message translates to:
  /// **'حذف المجلد'**
  String get bookmarksDeleteFolder;

  /// No description provided for @bookmarksDeleteFolderConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف المجلد «{name}»؟ ستبقى العلامات التي فيه دون مجلد.'**
  String bookmarksDeleteFolderConfirm(String name);

  /// No description provided for @bookmarkEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل العلامة'**
  String get bookmarkEdit;

  /// No description provided for @bookmarkLabel.
  ///
  /// In ar, this message translates to:
  /// **'وصف قصير (اختياري)'**
  String get bookmarkLabel;

  /// No description provided for @bookmarkFolder.
  ///
  /// In ar, this message translates to:
  /// **'المجلد'**
  String get bookmarkFolder;

  /// No description provided for @bookmarkRemove.
  ///
  /// In ar, this message translates to:
  /// **'إزالة العلامة'**
  String get bookmarkRemove;

  /// No description provided for @bookmarkAdded.
  ///
  /// In ar, this message translates to:
  /// **'أُضيفت العلامة'**
  String get bookmarkAdded;

  /// No description provided for @bookmarkRemoved.
  ///
  /// In ar, this message translates to:
  /// **'أُزيلت العلامة'**
  String get bookmarkRemoved;

  /// No description provided for @sortLabel.
  ///
  /// In ar, this message translates to:
  /// **'الترتيب'**
  String get sortLabel;

  /// No description provided for @sortNewest.
  ///
  /// In ar, this message translates to:
  /// **'الأحدث'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In ar, this message translates to:
  /// **'الأقدم'**
  String get sortOldest;

  /// No description provided for @sortCanonical.
  ///
  /// In ar, this message translates to:
  /// **'حسب ترتيب الكتاب'**
  String get sortCanonical;

  /// No description provided for @notesTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظاتي'**
  String get notesTitle;

  /// No description provided for @notesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ملاحظات بعد'**
  String get notesEmpty;

  /// No description provided for @notesEmptyHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف ملاحظة خاصة من قائمة أي حديث. الملاحظات تبقى على جهازك فقط.'**
  String get notesEmptyHint;

  /// No description provided for @notesSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في ملاحظاتك'**
  String get notesSearchHint;

  /// No description provided for @noteEditorTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة خاصة'**
  String get noteEditorTitle;

  /// No description provided for @noteHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب ملاحظتك…'**
  String get noteHint;

  /// No description provided for @notePrivateBadge.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة خاصة — ليست من نص الكتاب'**
  String get notePrivateBadge;

  /// No description provided for @noteDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الملاحظة'**
  String get noteDeleteTitle;

  /// No description provided for @noteDeleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف هذه الملاحظة نهائيًا؟'**
  String get noteDeleteConfirm;

  /// No description provided for @noteSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظت الملاحظة'**
  String get noteSaved;

  /// No description provided for @noteDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حُذفت الملاحظة'**
  String get noteDeleted;

  /// No description provided for @noteEmptyError.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظة فارغة'**
  String get noteEmptyError;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In ar, this message translates to:
  /// **'لغة الواجهة'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In ar, this message translates to:
  /// **'حسب النظام'**
  String get languageSystem;

  /// No description provided for @languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @settingsAppearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get settingsAppearance;

  /// No description provided for @settingsAppTheme.
  ///
  /// In ar, this message translates to:
  /// **'مظهر التطبيق'**
  String get settingsAppTheme;

  /// No description provided for @themeSystem.
  ///
  /// In ar, this message translates to:
  /// **'حسب النظام'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get themeDark;

  /// No description provided for @settingsReading.
  ///
  /// In ar, this message translates to:
  /// **'القراءة'**
  String get settingsReading;

  /// No description provided for @settingsSearchSection.
  ///
  /// In ar, this message translates to:
  /// **'البحث'**
  String get settingsSearchSection;

  /// No description provided for @settingsSearchBroadDefault.
  ///
  /// In ar, this message translates to:
  /// **'التسوية بين ة و ه افتراضيًا'**
  String get settingsSearchBroadDefault;

  /// No description provided for @settingsSearchWholeWordsDefault.
  ///
  /// In ar, this message translates to:
  /// **'البحث بالكلمات الكاملة افتراضيًا'**
  String get settingsSearchWholeWordsDefault;

  /// No description provided for @settingsTranslations.
  ///
  /// In ar, this message translates to:
  /// **'الترجمة'**
  String get settingsTranslations;

  /// No description provided for @settingsTranslationsNone.
  ///
  /// In ar, this message translates to:
  /// **'لا تتضمن هذه النسخة ترجمة.'**
  String get settingsTranslationsNone;

  /// No description provided for @settingsData.
  ///
  /// In ar, this message translates to:
  /// **'البيانات'**
  String get settingsData;

  /// No description provided for @backupExport.
  ///
  /// In ar, this message translates to:
  /// **'تصدير نسخة احتياطية'**
  String get backupExport;

  /// No description provided for @backupExportDescription.
  ///
  /// In ar, this message translates to:
  /// **'العلامات والملاحظات والتقدم والإعدادات في ملف JSON'**
  String get backupExportDescription;

  /// No description provided for @backupImport.
  ///
  /// In ar, this message translates to:
  /// **'استعادة نسخة احتياطية'**
  String get backupImport;

  /// No description provided for @backupImportDescription.
  ///
  /// In ar, this message translates to:
  /// **'من ملف JSON صدّرته سابقًا'**
  String get backupImportDescription;

  /// No description provided for @backupSections.
  ///
  /// In ar, this message translates to:
  /// **'ما الذي تريد تصديره؟'**
  String get backupSections;

  /// No description provided for @backupSectionBookmarks.
  ///
  /// In ar, this message translates to:
  /// **'العلامات والمجلدات'**
  String get backupSectionBookmarks;

  /// No description provided for @backupSectionNotes.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظات'**
  String get backupSectionNotes;

  /// No description provided for @backupSectionProgress.
  ///
  /// In ar, this message translates to:
  /// **'التقدم في القراءة'**
  String get backupSectionProgress;

  /// No description provided for @backupSectionHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل القراءة وآخر موضع'**
  String get backupSectionHistory;

  /// No description provided for @backupSectionSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get backupSectionSettings;

  /// No description provided for @backupImportConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'استبدال البيانات الحالية؟'**
  String get backupImportConfirmTitle;

  /// No description provided for @backupImportConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'ستُستبدل البيانات الحالية في هذه الأقسام بما في الملف: {sections}. لا يمكن التراجع.'**
  String backupImportConfirmBody(String sections);

  /// No description provided for @backupImportDone.
  ///
  /// In ar, this message translates to:
  /// **'اكتملت الاستعادة'**
  String get backupImportDone;

  /// No description provided for @backupInvalid.
  ///
  /// In ar, this message translates to:
  /// **'الملف غير صالح'**
  String get backupInvalid;

  /// No description provided for @backupExportSubject.
  ///
  /// In ar, this message translates to:
  /// **'نسخة احتياطية — صحيح البخاري'**
  String get backupExportSubject;

  /// No description provided for @settingsClearSearchHistory.
  ///
  /// In ar, this message translates to:
  /// **'مسح سجل البحث'**
  String get settingsClearSearchHistory;

  /// No description provided for @settingsClearReadingHistory.
  ///
  /// In ar, this message translates to:
  /// **'مسح سجل القراءة وآخر موضع'**
  String get settingsClearReadingHistory;

  /// No description provided for @settingsResetProgress.
  ///
  /// In ar, this message translates to:
  /// **'إعادة ضبط التقدم في القراءة'**
  String get settingsResetProgress;

  /// No description provided for @clearSearchConfirm.
  ///
  /// In ar, this message translates to:
  /// **'مسح كل عمليات البحث الأخيرة؟'**
  String get clearSearchConfirm;

  /// No description provided for @clearReadingConfirm.
  ///
  /// In ar, this message translates to:
  /// **'مسح الأحاديث المفتوحة مؤخرًا وآخر موضع قراءة؟ لن تتأثر العلامات والملاحظات.'**
  String get clearReadingConfirm;

  /// No description provided for @resetProgressConfirm.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء تعليم كل الأحاديث المقروءة؟ لن تتأثر العلامات والملاحظات.'**
  String get resetProgressConfirm;

  /// No description provided for @cleared.
  ///
  /// In ar, this message translates to:
  /// **'تم المسح'**
  String get cleared;

  /// No description provided for @settingsAbout.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق ومصادره'**
  String get settingsAbout;

  /// No description provided for @aboutTitle.
  ///
  /// In ar, this message translates to:
  /// **'المصادر والتراخيص'**
  String get aboutTitle;

  /// No description provided for @aboutSourcesTitle.
  ///
  /// In ar, this message translates to:
  /// **'مصدر النص'**
  String get aboutSourcesTitle;

  /// No description provided for @aboutSourceShamela.
  ///
  /// In ar, this message translates to:
  /// **'النص الرقمي: المكتبة الشاملة — كتاب «صحيح البخاري - ط التأصيل» (shamela.ws/book/1284).'**
  String get aboutSourceShamela;

  /// No description provided for @aboutSourceEdition.
  ///
  /// In ar, this message translates to:
  /// **'الطبعة: صحيح البخاري، مراجعة ومصححة على النسخة السلطانية مع رفع الالتباس عن رموزها. دار التأصيل، القاهرة، الطبعة الأولى ١٤٣٣هـ / ٢٠١٢م.'**
  String get aboutSourceEdition;

  /// No description provided for @aboutSourceNote.
  ///
  /// In ar, this message translates to:
  /// **'يُعرض النص كما هو في المصدر دون تعديل. يقتصر التطبيق على أسماء الكتب والأبواب ونصوص الأحاديث وأرقامها ومراجعها؛ حُذفت مقدمة التحقيق وحواشي المحقق وسائر المواد الإضافية.'**
  String get aboutSourceNote;

  /// No description provided for @aboutUsage.
  ///
  /// In ar, this message translates to:
  /// **'نسخة تجريبية خاصة وغير تجارية.'**
  String get aboutUsage;

  /// No description provided for @aboutVerification.
  ///
  /// In ar, this message translates to:
  /// **'قوبلت عينات من النص بصور الطبعة المطبوعة، وسُجّلت الفروق في وثيقة التحقق المرفقة مع المشروع.'**
  String get aboutVerification;

  /// No description provided for @aboutContentVersion.
  ///
  /// In ar, this message translates to:
  /// **'بصمة نسخة المحتوى: {hash}'**
  String aboutContentVersion(String hash);

  /// No description provided for @aboutFontsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخطوط'**
  String get aboutFontsTitle;

  /// No description provided for @aboutFontAmiri.
  ///
  /// In ar, this message translates to:
  /// **'خط أميري — مشروع أميري، رخصة SIL Open Font License 1.1'**
  String get aboutFontAmiri;

  /// No description provided for @aboutFontNoto.
  ///
  /// In ar, this message translates to:
  /// **'خطا Noto Naskh Arabic وNoto Sans Arabic — مشروع Noto، رخصة SIL Open Font License 1.1'**
  String get aboutFontNoto;

  /// No description provided for @aboutLicenses.
  ///
  /// In ar, this message translates to:
  /// **'تراخيص المكونات مفتوحة المصدر'**
  String get aboutLicenses;

  /// No description provided for @aboutPrivacyTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية'**
  String get aboutPrivacyTitle;

  /// No description provided for @aboutPrivacyBody.
  ///
  /// In ar, this message translates to:
  /// **'يعمل التطبيق دون اتصال بالإنترنت. لا حسابات ولا إعلانات ولا تحليلات. العلامات والملاحظات والتقدم محفوظة على جهازك فقط، ولا تغادره إلا إذا صدّرتها بنفسك.'**
  String get aboutPrivacyBody;

  /// No description provided for @aboutAppVersion.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version}'**
  String aboutAppVersion(String version);

  /// No description provided for @aboutNoTranslation.
  ///
  /// In ar, this message translates to:
  /// **'لا يتضمن التطبيق أي ترجمة أو شرح أو حكم على الأحاديث.'**
  String get aboutNoTranslation;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
