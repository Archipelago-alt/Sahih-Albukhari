// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sahih al-Bukhari';

  @override
  String get appSubtitle => 'al-Jami\' al-Musnad al-Sahih';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Try again';

  @override
  String get confirm => 'Confirm';

  @override
  String get edit => 'Edit';

  @override
  String get clear => 'Clear';

  @override
  String get loading => 'Loading…';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorBody => 'The operation could not be completed. Please try again.';

  @override
  String get contentInstallError =>
      'The book text could not be prepared on this device. The app package may be damaged; please reinstall it.';

  @override
  String get homeContinueReading => 'Continue reading';

  @override
  String get homeStartReading => 'Start reading';

  @override
  String get homeStartReadingHint => 'From the beginning: the start of revelation';

  @override
  String get homeLastRead => 'Last read';

  @override
  String get homeOverallProgress => 'Reading progress';

  @override
  String homeProgressDetail(String read, String total) {
    return '$read of $total read';
  }

  @override
  String get homeProgressNone => 'No hadith has been marked as read yet';

  @override
  String get homeBrowseBooks => 'Books';

  @override
  String get homeSearch => 'Search';

  @override
  String get homeBookmarks => 'Bookmarks';

  @override
  String get homeNotes => 'My notes';

  @override
  String get homeRecent => 'Recently read';

  @override
  String get homeRecentEmpty => 'Hadiths you open will appear here';

  @override
  String get homeSettings => 'Settings';

  @override
  String get booksTitle => 'Books';

  @override
  String get booksFilterHint => 'Filter book names';

  @override
  String get booksNoMatch => 'No book matches this name';

  @override
  String bookChapters(int count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText chapters',
      one: '1 chapter',
      zero: 'No chapters',
    );
    return '$_temp0';
  }

  @override
  String bookHadiths(int count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText hadiths',
      one: '1 hadith',
      zero: 'No hadiths',
    );
    return '$_temp0';
  }

  @override
  String percentRead(String percent) {
    return '$percent% read';
  }

  @override
  String get chaptersFilterHint => 'Filter chapter names';

  @override
  String get chaptersNoMatch => 'No chapter matches this name';

  @override
  String get chaptersExpandAll => 'Expand all';

  @override
  String get chaptersCollapseAll => 'Collapse all';

  @override
  String get chapterNoHadiths => 'The source has no hadith directly under this chapter';

  @override
  String get chapterMarkRead => 'Mark chapter as read';

  @override
  String get chapterMarkUnread => 'Mark chapter as unread';

  @override
  String get chapterOpen => 'Open chapter';

  @override
  String get bookIntroLabel => 'Book introduction';

  @override
  String get readWholeBook => 'Read the book from the start';

  @override
  String get readerTableOfContents => 'Contents';

  @override
  String get readerJumpToHadith => 'Go to hadith';

  @override
  String get readerJumpHint => 'Hadith number';

  @override
  String get readerJumpGo => 'Go';

  @override
  String readerHadithNotFound(String number) {
    return 'There is no hadith number $number';
  }

  @override
  String get readerPreviousHadith => 'Previous hadith';

  @override
  String get readerNextHadith => 'Next hadith';

  @override
  String get readerPreviousChapter => 'Previous chapter';

  @override
  String get readerNextChapter => 'Next chapter';

  @override
  String get readerSettings => 'Reading settings';

  @override
  String get readerBookmark => 'Bookmark';

  @override
  String get readerRemoveBookmark => 'Remove bookmark';

  @override
  String get readerAddNote => 'Add note';

  @override
  String get readerEditNote => 'Edit note';

  @override
  String get readerCopy => 'Copy hadith';

  @override
  String get readerShare => 'Share';

  @override
  String get readerMarkRead => 'Mark as read';

  @override
  String get readerMarkUnread => 'Mark as unread';

  @override
  String get readerCopied => 'Hadith copied';

  @override
  String get readerMore => 'More';

  @override
  String get readerEndOfBook => 'End of book';

  @override
  String get readerNextBook => 'Next book';

  @override
  String get readerPreviousBook => 'Previous book';

  @override
  String get readerRead => 'Read';

  @override
  String hadithNumberLabel(String number) {
    return 'Hadith $number';
  }

  @override
  String pageReference(String volume, String page) {
    return 'vol. $volume, p. $page';
  }

  @override
  String shareReference(String book, String chapter, String number, String page) {
    return 'Sahih al-Bukhari, $book, $chapter, hadith no. $number ($page). Dar al-Ta\'seel edition, text from al-Maktaba al-Shamela.';
  }

  @override
  String shareReferenceNoChapter(String book, String number, String page) {
    return 'Sahih al-Bukhari, $book, hadith no. $number ($page). Dar al-Ta\'seel edition, text from al-Maktaba al-Shamela.';
  }

  @override
  String get tuhfaLabel => 'Tuhfat al-Ashraf';

  @override
  String get showTuhfa => 'Show Tuhfat al-Ashraf reference';

  @override
  String get hideTuhfa => 'Hide Tuhfat al-Ashraf reference';

  @override
  String get tuhfaDisclaimer =>
      'The Tuhfat al-Ashraf number was added by the edition\'s editor; it is not part of the text of Sahih al-Bukhari.';

  @override
  String get readerCopyWithTuhfa => 'Copy with Tuhfat al-Ashraf reference';

  @override
  String get settingsFontSize => 'Font size';

  @override
  String get settingsLineHeight => 'Line spacing';

  @override
  String get settingsPagePadding => 'Page margins';

  @override
  String get settingsReaderTheme => 'Reading theme';

  @override
  String get readerThemeSystem => 'System';

  @override
  String get readerThemeLight => 'Light';

  @override
  String get readerThemeSepia => 'Sepia';

  @override
  String get readerThemeDark => 'Dark';

  @override
  String get settingsReadingFont => 'Reading font';

  @override
  String get fontAmiri => 'Amiri';

  @override
  String get fontNotoNaskh => 'Noto Naskh';

  @override
  String get settingsKeepAwake => 'Keep the screen on while reading';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search for a word, phrase or hadith number';

  @override
  String get searchModeAllWords => 'All words';

  @override
  String get searchModePhrase => 'Exact phrase';

  @override
  String get searchModeExact => 'Exact with diacritics';

  @override
  String get searchWholeWords => 'Whole words only';

  @override
  String get searchBroad => 'Treat ة and ه as the same';

  @override
  String get searchFilterBook => 'Book';

  @override
  String get searchFilterChapter => 'Chapter';

  @override
  String get searchAnyBook => 'All books';

  @override
  String get searchAnyChapter => 'All chapters';

  @override
  String searchResultCount(int count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText results',
      one: '1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get searchHeadingsTitle => 'In book and chapter names';

  @override
  String get searchHadithsTitle => 'In hadiths';

  @override
  String get searchNumberTitle => 'By number';

  @override
  String get searchNoResults => 'No results';

  @override
  String get searchNoResultsHint => 'Try fewer words, turn off \"Whole words only\", or treat ة and ه as the same.';

  @override
  String get searchRecent => 'Recent searches';

  @override
  String get searchClearHistory => 'Clear search history';

  @override
  String get searchStartHint => 'Search works offline. Letter normalization never changes the text you read.';

  @override
  String get searchOptions => 'Search options';

  @override
  String get bookmarksTitle => 'Bookmarks';

  @override
  String get bookmarksEmpty => 'No bookmarks yet';

  @override
  String get bookmarksEmptyHint => 'Bookmark a hadith from its menu while reading.';

  @override
  String get bookmarksAllFolders => 'All';

  @override
  String get bookmarksNoFolder => 'No folder';

  @override
  String get bookmarksNewFolder => 'New folder';

  @override
  String get bookmarksFolderName => 'Folder name';

  @override
  String get bookmarksRenameFolder => 'Rename';

  @override
  String get bookmarksDeleteFolder => 'Delete folder';

  @override
  String bookmarksDeleteFolderConfirm(String name) {
    return 'Delete the folder \"$name\"? Its bookmarks will be kept without a folder.';
  }

  @override
  String get bookmarkEdit => 'Edit bookmark';

  @override
  String get bookmarkLabel => 'Short label (optional)';

  @override
  String get bookmarkFolder => 'Folder';

  @override
  String get bookmarkRemove => 'Remove bookmark';

  @override
  String get bookmarkAdded => 'Bookmark added';

  @override
  String get bookmarkRemoved => 'Bookmark removed';

  @override
  String get sortLabel => 'Sort';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortOldest => 'Oldest';

  @override
  String get sortCanonical => 'Book order';

  @override
  String get notesTitle => 'My notes';

  @override
  String get notesEmpty => 'No notes yet';

  @override
  String get notesEmptyHint => 'Add a private note from any hadith\'s menu. Notes stay on this device.';

  @override
  String get notesSearchHint => 'Search your notes';

  @override
  String get noteEditorTitle => 'Private note';

  @override
  String get noteHint => 'Write your note…';

  @override
  String get notePrivateBadge => 'Private note — not part of the book';

  @override
  String get noteDeleteTitle => 'Delete note';

  @override
  String get noteDeleteConfirm => 'Delete this note permanently?';

  @override
  String get noteSaved => 'Note saved';

  @override
  String get noteDeleted => 'Note deleted';

  @override
  String get noteEmptyError => 'The note is empty';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'App language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAppTheme => 'App theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsReading => 'Reading';

  @override
  String get settingsSearchSection => 'Search';

  @override
  String get settingsSearchBroadDefault => 'Treat ة and ه as the same by default';

  @override
  String get settingsSearchWholeWordsDefault => 'Match whole words by default';

  @override
  String get settingsTranslations => 'Translation';

  @override
  String get settingsTranslationsNone => 'This edition includes no translation.';

  @override
  String get settingsData => 'Data';

  @override
  String get backupExport => 'Export a backup';

  @override
  String get backupExportDescription => 'Bookmarks, notes, progress and settings as a JSON file';

  @override
  String get backupImport => 'Restore a backup';

  @override
  String get backupImportDescription => 'From a JSON file you exported earlier';

  @override
  String get backupSections => 'What should be exported?';

  @override
  String get backupSectionBookmarks => 'Bookmarks and folders';

  @override
  String get backupSectionNotes => 'Notes';

  @override
  String get backupSectionProgress => 'Reading progress';

  @override
  String get backupSectionHistory => 'Reading history and last position';

  @override
  String get backupSectionSettings => 'Settings';

  @override
  String get backupImportConfirmTitle => 'Replace current data?';

  @override
  String backupImportConfirmBody(String sections) {
    return 'Your current data in these sections will be replaced by the file\'s: $sections. This cannot be undone.';
  }

  @override
  String get backupImportDone => 'Restore complete';

  @override
  String get backupInvalid => 'The file is not valid';

  @override
  String get backupExportSubject => 'Backup — Sahih al-Bukhari';

  @override
  String get settingsClearSearchHistory => 'Clear search history';

  @override
  String get settingsClearReadingHistory => 'Clear reading history and last position';

  @override
  String get settingsResetProgress => 'Reset reading progress';

  @override
  String get clearSearchConfirm => 'Clear all recent searches?';

  @override
  String get clearReadingConfirm =>
      'Clear recently opened hadiths and the last reading position? Bookmarks and notes are not affected.';

  @override
  String get resetProgressConfirm => 'Unmark every hadith marked as read? Bookmarks and notes are not affected.';

  @override
  String get cleared => 'Cleared';

  @override
  String get settingsAbout => 'About and data sources';

  @override
  String get aboutTitle => 'Sources and licences';

  @override
  String get aboutSourcesTitle => 'Source of the text';

  @override
  String get aboutSourceShamela =>
      'Digital text: al-Maktaba al-Shamela — \"Sahih al-Bukhari - Dar al-Ta\'seel edition\" (shamela.ws/book/1284).';

  @override
  String get aboutSourceEdition =>
      'Edition: Sahih al-Bukhari, revised and corrected against the Sultaniyya edition. Dar al-Ta\'seel, Cairo, 1st edition, 1433 AH / 2012 CE.';

  @override
  String get aboutSourceNote =>
      'The text is shown exactly as in the source. The app contains only the book names, chapter names, hadith texts, their numbering and references; the editor\'s introduction, the editor\'s footnotes and other supplementary material are omitted.';

  @override
  String get aboutUsage => 'Private, non-commercial test build.';

  @override
  String get aboutVerification =>
      'Samples of the text were compared with images of the printed edition; the differences are recorded in the project\'s verification document.';

  @override
  String aboutContentVersion(String hash) {
    return 'Content fingerprint: $hash';
  }

  @override
  String get aboutFontsTitle => 'Fonts';

  @override
  String get aboutFontAmiri => 'Amiri — The Amiri Project Authors, SIL Open Font License 1.1';

  @override
  String get aboutFontNoto =>
      'Noto Naskh Arabic and Noto Sans Arabic — The Noto Project Authors, SIL Open Font License 1.1';

  @override
  String get aboutLicenses => 'Open-source licences';

  @override
  String get aboutPrivacyTitle => 'Privacy';

  @override
  String get aboutPrivacyBody =>
      'The app works offline. No accounts, advertising or analytics. Bookmarks, notes and progress are stored only on your device and never leave it unless you export them yourself.';

  @override
  String aboutAppVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutNoTranslation => 'The app contains no translation, commentary or grading of hadiths.';
}
