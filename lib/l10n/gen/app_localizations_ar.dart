// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'صحيح البخاري';

  @override
  String get appSubtitle => 'الجامع المسند الصحيح';

  @override
  String get cancel => 'إلغاء';

  @override
  String get ok => 'حسنًا';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get close => 'إغلاق';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get confirm => 'تأكيد';

  @override
  String get edit => 'تعديل';

  @override
  String get clear => 'مسح';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get errorTitle => 'حدث خطأ';

  @override
  String get errorBody => 'تعذّر إكمال العملية. حاول مرة أخرى.';

  @override
  String get contentInstallError => 'تعذّر تجهيز نص الكتاب على هذا الجهاز. قد يكون ملف التطبيق تالفًا؛ أعد تثبيته.';

  @override
  String get homeContinueReading => 'متابعة القراءة';

  @override
  String get homeStartReading => 'ابدأ القراءة';

  @override
  String get homeStartReadingHint => 'من أول الكتاب: بدء الوحي';

  @override
  String get homeLastRead => 'آخر ما قرأت';

  @override
  String get homeOverallProgress => 'التقدم في القراءة';

  @override
  String homeProgressDetail(String read, String total) {
    return 'قرأت $read من $total';
  }

  @override
  String get homeProgressNone => 'لم تُعلَّم أي أحاديث كمقروءة بعد';

  @override
  String get homeBrowseBooks => 'الكتب';

  @override
  String get homeSearch => 'البحث';

  @override
  String get homeBookmarks => 'العلامات';

  @override
  String get homeNotes => 'ملاحظاتي';

  @override
  String get homeRecent => 'قُرئ مؤخرًا';

  @override
  String get homeRecentEmpty => 'ستظهر هنا الأحاديث التي فتحتها مؤخرًا';

  @override
  String get homeSettings => 'الإعدادات';

  @override
  String get booksTitle => 'الكتب';

  @override
  String get booksFilterHint => 'ابحث في أسماء الكتب';

  @override
  String get booksNoMatch => 'لا يوجد كتاب بهذا الاسم';

  @override
  String bookChapters(int count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText باب',
      many: '$countText بابًا',
      few: '$countText أبواب',
      two: 'بابان',
      one: 'باب واحد',
      zero: 'بلا أبواب',
    );
    return '$_temp0';
  }

  @override
  String bookHadiths(int count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText حديث',
      many: '$countText حديثًا',
      few: '$countText أحاديث',
      two: 'حديثان',
      one: 'حديث واحد',
      zero: 'بلا أحاديث',
    );
    return '$_temp0';
  }

  @override
  String percentRead(String percent) {
    return 'قُرئ $percent٪';
  }

  @override
  String get chaptersFilterHint => 'ابحث في أسماء الأبواب';

  @override
  String get chaptersNoMatch => 'لا يوجد باب بهذا الاسم';

  @override
  String get chaptersExpandAll => 'توسيع الكل';

  @override
  String get chaptersCollapseAll => 'طي الكل';

  @override
  String get chapterNoHadiths => 'لا حديث تحت هذا الباب في الأصل';

  @override
  String get chapterMarkRead => 'تعليم الباب كمقروء';

  @override
  String get chapterMarkUnread => 'إلغاء تعليم الباب';

  @override
  String get chapterOpen => 'افتح الباب';

  @override
  String get bookIntroLabel => 'مقدمة الكتاب';

  @override
  String get readWholeBook => 'اقرأ الكتاب من أوله';

  @override
  String get readerTableOfContents => 'الفهرس';

  @override
  String get readerJumpToHadith => 'انتقل إلى حديث';

  @override
  String get readerJumpHint => 'رقم الحديث';

  @override
  String get readerJumpGo => 'انتقال';

  @override
  String readerHadithNotFound(String number) {
    return 'لا يوجد حديث برقم $number';
  }

  @override
  String get readerPreviousHadith => 'الحديث السابق';

  @override
  String get readerNextHadith => 'الحديث التالي';

  @override
  String get readerPreviousChapter => 'الباب السابق';

  @override
  String get readerNextChapter => 'الباب التالي';

  @override
  String get readerSettings => 'إعدادات القراءة';

  @override
  String get readerBookmark => 'إضافة علامة';

  @override
  String get readerRemoveBookmark => 'إزالة العلامة';

  @override
  String get readerAddNote => 'إضافة ملاحظة';

  @override
  String get readerEditNote => 'تعديل الملاحظة';

  @override
  String get readerCopy => 'نسخ الحديث';

  @override
  String get readerCopyWithFootnotes => 'نسخ مع حواشي المحقق';

  @override
  String get readerShare => 'مشاركة';

  @override
  String get readerMarkRead => 'تعليم كمقروء';

  @override
  String get readerMarkUnread => 'إلغاء تعليم القراءة';

  @override
  String get readerCopied => 'نُسخ الحديث';

  @override
  String get readerMore => 'المزيد';

  @override
  String get readerEndOfBook => 'نهاية الكتاب';

  @override
  String get readerNextBook => 'الكتاب التالي';

  @override
  String get readerPreviousBook => 'الكتاب السابق';

  @override
  String get readerRead => 'مقروء';

  @override
  String hadithNumberLabel(String number) {
    return 'حديث رقم $number';
  }

  @override
  String pageReference(String volume, String page) {
    return 'ج$volume ص$page';
  }

  @override
  String shareReference(String book, String chapter, String number, String page) {
    return 'صحيح البخاري، $book، $chapter، حديث رقم $number ($page). ط. دار التأصيل، نص المكتبة الشاملة.';
  }

  @override
  String shareReferenceNoChapter(String book, String number, String page) {
    return 'صحيح البخاري، $book، حديث رقم $number ($page). ط. دار التأصيل، نص المكتبة الشاملة.';
  }

  @override
  String get editorNotesTitle => 'حواشي المحقق';

  @override
  String get editorNotesDisclaimer => 'هذه الحواشي من عمل محقق الطبعة، وليست من نص صحيح البخاري.';

  @override
  String footnoteTitle(String marker) {
    return 'حاشية $marker';
  }

  @override
  String get footnoteMissing => 'لا توجد حاشية بهذا الرقم في المصدر.';

  @override
  String get tuhfaLabel => 'تحفة الأشراف';

  @override
  String get showEditorNotes => 'عرض حواشي المحقق';

  @override
  String get hideEditorNotes => 'إخفاء حواشي المحقق';

  @override
  String get settingsFontSize => 'حجم الخط';

  @override
  String get settingsLineHeight => 'تباعد الأسطر';

  @override
  String get settingsPagePadding => 'هوامش الصفحة';

  @override
  String get settingsReaderTheme => 'مظهر القراءة';

  @override
  String get readerThemeSystem => 'حسب النظام';

  @override
  String get readerThemeLight => 'فاتح';

  @override
  String get readerThemeSepia => 'بني فاتح';

  @override
  String get readerThemeDark => 'داكن';

  @override
  String get settingsReadingFont => 'خط القراءة';

  @override
  String get fontAmiri => 'أميري';

  @override
  String get fontNotoNaskh => 'نوتو نسخ';

  @override
  String get settingsKeepAwake => 'إبقاء الشاشة مضاءة أثناء القراءة';

  @override
  String get settingsShowFootnoteMarkers => 'إظهار أرقام حواشي المحقق في النص';

  @override
  String get searchTitle => 'البحث';

  @override
  String get searchHint => 'ابحث عن كلمة أو عبارة أو رقم حديث';

  @override
  String get searchModeAllWords => 'كل الكلمات';

  @override
  String get searchModePhrase => 'عبارة متصلة';

  @override
  String get searchModeExact => 'مطابق بالتشكيل';

  @override
  String get searchWholeWords => 'كلمات كاملة فقط';

  @override
  String get searchBroad => 'التسوية بين ة و ه';

  @override
  String get searchFilterBook => 'الكتاب';

  @override
  String get searchFilterChapter => 'الباب';

  @override
  String get searchAnyBook => 'كل الكتب';

  @override
  String get searchAnyChapter => 'كل الأبواب';

  @override
  String searchResultCount(int count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText نتيجة',
      many: '$countText نتيجة',
      few: '$countText نتائج',
      two: 'نتيجتان',
      one: 'نتيجة واحدة',
      zero: 'لا نتائج',
    );
    return '$_temp0';
  }

  @override
  String get searchHeadingsTitle => 'في أسماء الكتب والأبواب';

  @override
  String get searchHadithsTitle => 'في الأحاديث';

  @override
  String get searchNumberTitle => 'بالرقم';

  @override
  String get searchNoResults => 'لا توجد نتائج';

  @override
  String get searchNoResultsHint => 'جرّب كلمات أقل، أو ألغِ خيار «كلمات كاملة فقط»، أو فعّل التسوية بين ة و ه.';

  @override
  String get searchRecent => 'عمليات البحث الأخيرة';

  @override
  String get searchClearHistory => 'مسح سجل البحث';

  @override
  String get searchStartHint => 'يعمل البحث دون اتصال. لا تؤثر التسوية بين الحروف على النص المعروض.';

  @override
  String get searchOptions => 'خيارات البحث';

  @override
  String get bookmarksTitle => 'العلامات';

  @override
  String get bookmarksEmpty => 'لا توجد علامات بعد';

  @override
  String get bookmarksEmptyHint => 'أضف علامة من قائمة أي حديث أثناء القراءة.';

  @override
  String get bookmarksAllFolders => 'الكل';

  @override
  String get bookmarksNoFolder => 'بلا مجلد';

  @override
  String get bookmarksNewFolder => 'مجلد جديد';

  @override
  String get bookmarksFolderName => 'اسم المجلد';

  @override
  String get bookmarksRenameFolder => 'إعادة التسمية';

  @override
  String get bookmarksDeleteFolder => 'حذف المجلد';

  @override
  String bookmarksDeleteFolderConfirm(String name) {
    return 'حذف المجلد «$name»؟ ستبقى العلامات التي فيه دون مجلد.';
  }

  @override
  String get bookmarkEdit => 'تعديل العلامة';

  @override
  String get bookmarkLabel => 'وصف قصير (اختياري)';

  @override
  String get bookmarkFolder => 'المجلد';

  @override
  String get bookmarkRemove => 'إزالة العلامة';

  @override
  String get bookmarkAdded => 'أُضيفت العلامة';

  @override
  String get bookmarkRemoved => 'أُزيلت العلامة';

  @override
  String get sortLabel => 'الترتيب';

  @override
  String get sortNewest => 'الأحدث';

  @override
  String get sortOldest => 'الأقدم';

  @override
  String get sortCanonical => 'حسب ترتيب الكتاب';

  @override
  String get notesTitle => 'ملاحظاتي';

  @override
  String get notesEmpty => 'لا توجد ملاحظات بعد';

  @override
  String get notesEmptyHint => 'أضف ملاحظة خاصة من قائمة أي حديث. الملاحظات تبقى على جهازك فقط.';

  @override
  String get notesSearchHint => 'ابحث في ملاحظاتك';

  @override
  String get noteEditorTitle => 'ملاحظة خاصة';

  @override
  String get noteHint => 'اكتب ملاحظتك…';

  @override
  String get notePrivateBadge => 'ملاحظة خاصة — ليست من نص الكتاب';

  @override
  String get noteDeleteTitle => 'حذف الملاحظة';

  @override
  String get noteDeleteConfirm => 'هل تريد حذف هذه الملاحظة نهائيًا؟';

  @override
  String get noteSaved => 'حُفظت الملاحظة';

  @override
  String get noteDeleted => 'حُذفت الملاحظة';

  @override
  String get noteEmptyError => 'الملاحظة فارغة';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguage => 'لغة الواجهة';

  @override
  String get languageSystem => 'حسب النظام';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsAppTheme => 'مظهر التطبيق';

  @override
  String get themeSystem => 'حسب النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get settingsReading => 'القراءة';

  @override
  String get settingsSearchSection => 'البحث';

  @override
  String get settingsSearchBroadDefault => 'التسوية بين ة و ه افتراضيًا';

  @override
  String get settingsSearchWholeWordsDefault => 'البحث بالكلمات الكاملة افتراضيًا';

  @override
  String get settingsTranslations => 'الترجمة';

  @override
  String get settingsTranslationsNone => 'لا تتضمن هذه النسخة ترجمة.';

  @override
  String get settingsData => 'البيانات';

  @override
  String get backupExport => 'تصدير نسخة احتياطية';

  @override
  String get backupExportDescription => 'العلامات والملاحظات والتقدم والإعدادات في ملف JSON';

  @override
  String get backupImport => 'استعادة نسخة احتياطية';

  @override
  String get backupImportDescription => 'من ملف JSON صدّرته سابقًا';

  @override
  String get backupSections => 'ما الذي تريد تصديره؟';

  @override
  String get backupSectionBookmarks => 'العلامات والمجلدات';

  @override
  String get backupSectionNotes => 'الملاحظات';

  @override
  String get backupSectionProgress => 'التقدم في القراءة';

  @override
  String get backupSectionHistory => 'سجل القراءة وآخر موضع';

  @override
  String get backupSectionSettings => 'الإعدادات';

  @override
  String get backupImportConfirmTitle => 'استبدال البيانات الحالية؟';

  @override
  String backupImportConfirmBody(String sections) {
    return 'ستُستبدل البيانات الحالية في هذه الأقسام بما في الملف: $sections. لا يمكن التراجع.';
  }

  @override
  String get backupImportDone => 'اكتملت الاستعادة';

  @override
  String get backupInvalid => 'الملف غير صالح';

  @override
  String get backupExportSubject => 'نسخة احتياطية — صحيح البخاري';

  @override
  String get settingsClearSearchHistory => 'مسح سجل البحث';

  @override
  String get settingsClearReadingHistory => 'مسح سجل القراءة وآخر موضع';

  @override
  String get settingsResetProgress => 'إعادة ضبط التقدم في القراءة';

  @override
  String get clearSearchConfirm => 'مسح كل عمليات البحث الأخيرة؟';

  @override
  String get clearReadingConfirm => 'مسح الأحاديث المفتوحة مؤخرًا وآخر موضع قراءة؟ لن تتأثر العلامات والملاحظات.';

  @override
  String get resetProgressConfirm => 'إلغاء تعليم كل الأحاديث المقروءة؟ لن تتأثر العلامات والملاحظات.';

  @override
  String get cleared => 'تم المسح';

  @override
  String get settingsAbout => 'عن التطبيق ومصادره';

  @override
  String get aboutTitle => 'المصادر والتراخيص';

  @override
  String get aboutSourcesTitle => 'مصدر النص';

  @override
  String get aboutSourceShamela =>
      'النص الرقمي: المكتبة الشاملة — كتاب «صحيح البخاري - ط التأصيل» (shamela.ws/book/1284).';

  @override
  String get aboutSourceEdition =>
      'الطبعة: صحيح البخاري، مراجعة ومصححة على النسخة السلطانية مع رفع الالتباس عن رموزها. دار التأصيل، القاهرة، الطبعة الأولى ١٤٣٣هـ / ٢٠١٢م.';

  @override
  String get aboutSourceNote =>
      'يُعرض النص كما هو في المصدر دون تعديل. حُذفت مقدمة التحقيق. حواشي المحقق معروضة منفصلة عن النص.';

  @override
  String get aboutVerification =>
      'قوبلت عينات من النص بصور الطبعة المطبوعة، وسُجّلت الفروق في وثيقة التحقق المرفقة مع المشروع.';

  @override
  String aboutContentVersion(String hash) {
    return 'بصمة نسخة المحتوى: $hash';
  }

  @override
  String get aboutFontsTitle => 'الخطوط';

  @override
  String get aboutFontAmiri => 'خط أميري — مشروع أميري، رخصة SIL Open Font License 1.1';

  @override
  String get aboutFontNoto => 'خطا Noto Naskh Arabic وNoto Sans Arabic — مشروع Noto، رخصة SIL Open Font License 1.1';

  @override
  String get aboutLicenses => 'تراخيص المكونات مفتوحة المصدر';

  @override
  String get aboutPrivacyTitle => 'الخصوصية';

  @override
  String get aboutPrivacyBody =>
      'يعمل التطبيق دون اتصال بالإنترنت. لا حسابات ولا إعلانات ولا تحليلات. العلامات والملاحظات والتقدم محفوظة على جهازك فقط، ولا تغادره إلا إذا صدّرتها بنفسك.';

  @override
  String aboutAppVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get aboutNoTranslation => 'لا يتضمن التطبيق أي ترجمة أو شرح أو حكم على الأحاديث.';
}
