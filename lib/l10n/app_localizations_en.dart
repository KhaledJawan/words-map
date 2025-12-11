// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsChangeLanguage => 'Change Language';

  @override
  String get tabHome => 'Home';

  @override
  String get tabLessons => 'Lessons';

  @override
  String get tabProfile => 'Profile';

  @override
  String get totalWordsLabel => 'Total words';

  @override
  String get settingsLanguageFarsi => 'فارسی';

  @override
  String get loadWordsFailed => 'Failed to load words.';

  @override
  String get settingsSelectLanguageTitle => 'Select language';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageDescription => 'App interface language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeDescription => 'Choose app appearance';

  @override
  String get settingsThemeSystem => 'System default';

  @override
  String get settingsThemeLight => 'Light mode';

  @override
  String get settingsThemeDark => 'Dark mode';

  @override
  String get settingsNotificationsTitle => 'Notifications & Reminders';

  @override
  String get settingsNotifications => 'App notifications';

  @override
  String get settingsNotificationsDescription => 'App alerts and daily check-ins';

  @override
  String get settingsDailyReminder => 'Daily reminder';

  @override
  String get lessonsTitle => 'Lessons';

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
  String get lessonsCategoryBeginnerBasics => 'Beginner Basics';

  @override
  String get lessonsCategoryGrammar => 'Grammar';

  @override
  String get lessonsCategoryReadingListening => 'Reading & Listening';

  @override
  String get lessonsCategoryExamPractice => 'Exam Practice';

  @override
  String get grammarLevelA1 => 'A1 Grammar';

  @override
  String get grammarLevelA2 => 'A2 Grammar';

  @override
  String get grammarLevelB1 => 'B1 Grammar';

  @override
  String get grammarLevelB2 => 'B2 Grammar';

  @override
  String get grammarLevelC1 => 'C1 Grammar';

  @override
  String grammarLevelLessonsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '1 lesson',
      zero: 'No lessons yet',
    );
    return '$_temp0';
  }

  @override
  String get lessonsStatusComingSoon => 'Coming soon';

  @override
  String get lessonButtonNext => 'Next';

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
    return 'Chapter $chapter overview';
  }

  @override
  String get chooseChapter => 'Choose your chapter';

  @override
  String get chapterEmptyState => 'No words in this chapter yet.';

  @override
  String get bookmarkedLabel => 'Bookmarked';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get viewedLabel => 'Viewed';

  @override
  String get lessonCompleted => 'Completed';

  @override
  String get lessonRepeat => 'Repeat';

  @override
  String get lessonRepeatAgain => 'Repeat again';
}
