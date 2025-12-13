// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get settingsTitle => 'تنظیمات';

  @override
  String get settingsChangeLanguage => 'تغییر زبان';

  @override
  String get tabHome => 'خانه';

  @override
  String get tabLessons => 'درس‌ها';

  @override
  String get tabProfile => 'حساب کاربری';

  @override
  String get totalWordsLabel => 'Total words';

  @override
  String get settingsLanguageFarsi => 'فارسی';

  @override
  String get loadWordsFailed => 'Failed to load words.';

  @override
  String get settingsSelectLanguageTitle => 'انتخاب زبان';

  @override
  String get settingsLanguage => 'زبان';

  @override
  String get settingsLanguageDescription => 'زبان رابط کاربری اپ';

  @override
  String get settingsTheme => 'پوسته';

  @override
  String get settingsThemeDescription => 'انتخاب ظاهر اپ';

  @override
  String get settingsThemeSystem => 'پیش‌فرض سیستم';

  @override
  String get settingsThemeLight => 'حالت روشن';

  @override
  String get settingsThemeDark => 'حالت تاریک';

  @override
  String get settingsNotificationsTitle => 'اعلان‌ها و یادآورها';

  @override
  String get settingsNotifications => 'اعلان‌های اپ';

  @override
  String get settingsNotificationsDescription => 'هشدارهای اپ و یادآوری‌های روزانه';

  @override
  String get settingsDailyReminder => 'یادآور روزانه';

  @override
  String get lessonsTitle => 'درس‌ها';

  @override
  String get lessonBeginnerAlphabetTitle => 'Alphabet';

  @override
  String get lessonBeginnerReadingRulesTitle => 'Reading rules';

  @override
  String get lessonBeginnerPartsOfSpeechTitle => 'Parts of speech';

  @override
  String get lessonBeginnerHalloTitle => 'Hallo';

  @override
  String get lessonBeginnerAllAboutGermanTitle => 'All about German';

  @override
  String get lessonsCategoryBeginnerBasics => 'مبانی مقدماتی';

  @override
  String get lessonsCategoryGrammar => 'دستور زبان';

  @override
  String get lessonsCategoryReadingListening => 'خواندن و شنیدن';

  @override
  String get lessonsCategoryExamPractice => 'تمرین آزمون';

  @override
  String get grammarLevelA1 => 'گرامر A1';

  @override
  String get grammarLevelA2 => 'گرامر A2';

  @override
  String get grammarLevelB1 => 'گرامر B1';

  @override
  String get grammarLevelB2 => 'گرامر B2';

  @override
  String get grammarLevelC1 => 'گرامر C1';

  @override
  String grammarLevelLessonsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count درس',
      one: '1 درس',
      zero: 'هنوز درسی نیست',
    );
    return '$_temp0';
  }

  @override
  String get lessonsStatusComingSoon => 'به‌زودی';

  @override
  String get grammarContentLoadError => 'بارگذاری محتوای گرامر با خطا مواجه شد.';

  @override
  String get lessonExamplesTitle => 'نمونه‌ها';

  @override
  String get grammarTopicComingSoon => 'محتوا به‌زودی اضافه می‌شود.';

  @override
  String get lessonButtonNext => 'بعدی';

  @override
  String get slideAlphabetOverviewTitle => 'German Alphabet – Overview';

  @override
  String get slideAlphabetVowelsTitle => 'Vowels (A, E, I, O, U)';

  @override
  String get slideAlphabetUmlautTitle => 'Umlaut vowels (Ä, Ö, Ü)';

  @override
  String get slideAlphabetEsszettTitle => 'ß – Eszett';

  @override
  String get slideReadingBasicRuleTitle => 'Basic reading rule – “ie” vs “ei”';

  @override
  String get slideReadingSchChSpStTitle => '“sch”, “ch” and “sp / st”';

  @override
  String get slideReadingCapitalLettersTitle => 'Capital letters (Nouns)';

  @override
  String get slideReadingLongVsShortTitle => 'Long vs short vowels';

  @override
  String get slidePartsMainPartsTitle => 'Main parts of speech';

  @override
  String get slidePartsNounsGenderTitle => 'Nouns and gender';

  @override
  String get slidePartsVerbsInfinitiveTitle => 'Verbs in basic form (Infinitiv)';

  @override
  String get slidePartsAdjectivesTitle => 'Adjectives – describing words';

  @override
  String get slideHalloBasicGreetingsTitle => 'Basic greetings';

  @override
  String get slideHalloIntroducingTitle => 'Introducing yourself';

  @override
  String get slideHalloHowAreYouTitle => 'Asking “How are you?”';

  @override
  String get slideHalloPoliteWordsTitle => 'Polite words';

  @override
  String get slideGermanWhereSpokenTitle => 'Where is German spoken?';

  @override
  String get slideGermanFormalInformalTitle => 'Formal vs informal “you”';

  @override
  String get slideGermanWordOrderTitle => 'Word order – basic idea';

  @override
  String get slideGermanLongWordsTitle => 'Don’t be afraid of long words';

  @override
  String chapterOverview(Object chapter) {
    return 'Chapter overview';
  }

  @override
  String get chooseChapter => 'Choose your chapter';

  @override
  String get chapterEmptyState => 'No words in this chapter yet.';

  @override
  String get bookmarkedLabel => 'Bookmarked';

  @override
  String get settingsLanguageEnglish => 'انگلیسی';

  @override
  String get viewedLabel => 'Viewed';

  @override
  String get lessonCompleted => 'یاد گرفتم';

  @override
  String get lessonRepeat => 'Repeat';

  @override
  String get lessonRepeatAgain => 'Repeat again';
}
