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
  String get settingsAppLanguageTitle => 'App language';

  @override
  String get settingsWordLanguagesTitle => 'Word language(s)';

  @override
  String get settingsSelectWordLanguagesTitle => 'Word languages';

  @override
  String get settingsSelectWordLanguagesHint => 'Choose 1 or 2';

  @override
  String get settingsWordLanguagesMaxTwo => 'You can select up to 2 languages.';

  @override
  String get settingsWordLanguagesMinOne => 'Select at least one language.';

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
  String get settingsLanguagePashto => 'پښتو';

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
  String get grammarContentLoadError => 'Failed to load grammar content.';

  @override
  String get lessonExamplesTitle => 'Examples';

  @override
  String get grammarTopicComingSoon => 'Content will be added later.';

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

  @override
  String get chapterCategories => 'Categories';

  @override
  String get chooseCategory => 'Choose a category';

  @override
  String get categoryEmptyState => 'No words in this category yet.';

  @override
  String categoryOverview(Object category) {
    return 'Category $category overview';
  }

  @override
  String get homeSupportTitle => '☕️ Support WordMap';

  @override
  String get homeSupportBody => 'German got you like… 🤯?\nTap 💎 to keep the tea brewing ☕️❤️';

  @override
  String get homeSupportSupportButton => 'Support';

  @override
  String get homeSupportCloseTooltip => 'Close';

  @override
  String get commonClose => 'Close';

  @override
  String get commonLesson => 'Lesson';

  @override
  String get lessonLoadFailed => 'Failed to load lesson.';

  @override
  String get audioPlaybackFailed => 'Audio couldn’t be played.';

  @override
  String get adLoading => 'Ad is loading…';

  @override
  String get noMoreWordsTitle => 'No more words';

  @override
  String get noMoreWordsBody => 'You reached 0. Watch an ad to activate 💎 mode for 1 hour (unlimited words), or wait 1 hour to get 50 words back.';

  @override
  String get noMoreWordsWaitOneHour => 'Wait 1 hour';

  @override
  String get noMoreWordsWatchAd => 'Watch ad';

  @override
  String get diamondBadgeSubtitleActive => 'Diamond';

  @override
  String get diamondBadgeSubtitleInactive => 'Left';

  @override
  String get diamondBadgeSubtitleCooldown => 'Cooldown';

  @override
  String cooldownActive(Object time) {
    return 'Try again in $time';
  }

  @override
  String get updateAvailableTitle => 'New version available';

  @override
  String get updateAvailableBody => 'Please update WordMap to get the latest features.';

  @override
  String get updateAvailableLater => 'Later';

  @override
  String get updateAvailableUpdate => 'Update';

  @override
  String authError(Object error) {
    return 'Authentication error: $error';
  }

  @override
  String get tagA1Core => 'A1 core';

  @override
  String get tagDailyLife => 'Daily life';

  @override
  String get tagConversationPhrases => 'Conversation phrases';

  @override
  String get tagGreetingsPoliteness => 'Greetings & politeness';

  @override
  String get tagQuestionsAnswers => 'Questions & answers';

  @override
  String get tagTimeDate => 'Time & date';

  @override
  String get tagNumbersMath => 'Numbers & math';

  @override
  String get tagColorsShapes => 'Colors & shapes';

  @override
  String get tagDaysMonthsSeasons => 'Days, months & seasons';

  @override
  String get tagWeather => 'Weather';

  @override
  String get tagDirectionsNavigation => 'Directions & navigation';

  @override
  String get tagPlacesBuildings => 'Places & buildings';

  @override
  String get tagCityTransport => 'City & transport';

  @override
  String get tagTravelHolidays => 'Travel & holidays';

  @override
  String get tagHomeHousehold => 'Home & household';

  @override
  String get tagFurnitureRooms => 'Furniture & rooms';

  @override
  String get tagKitchenCooking => 'Kitchen & cooking';

  @override
  String get tagFoodDrink => 'Food & drink';

  @override
  String get tagShoppingMoney => 'Shopping & money';

  @override
  String get tagClothingFashion => 'Clothing & fashion';

  @override
  String get tagHealthBody => 'Health & body';

  @override
  String get tagFeelingsEmotions => 'Feelings & emotions';

  @override
  String get tagPeopleFamily => 'People & family';

  @override
  String get tagRelationships => 'Relationships';

  @override
  String get tagSchoolLearning => 'School & learning';

  @override
  String get tagWorkOffice => 'Work & office';

  @override
  String get tagJobsProfessions => 'Jobs & professions';

  @override
  String get tagTechnologyInternet => 'Technology & internet';

  @override
  String get tagMediaSocial => 'Media & social';

  @override
  String get tagHobbiesSports => 'Hobbies & sports';

  @override
  String get tagNatureAnimals => 'Nature & animals';

  @override
  String get tagPlantsEnvironment => 'Plants & environment';

  @override
  String get tagCultureEvents => 'Culture & events';

  @override
  String get tagServicesAuthorities => 'Services & authorities';

  @override
  String get tagReligionCulture => 'Religion & culture';

  @override
  String get tagSafetyEmergency => 'Safety & emergency';

  @override
  String get tagLawRules => 'Law & rules';

  @override
  String get tagVerb => 'Verb';

  @override
  String get tagNoun => 'Noun';

  @override
  String get tagAdjective => 'Adjective';

  @override
  String get tagAdverb => 'Adverb';

  @override
  String get tagPronoun => 'Pronoun';

  @override
  String get tagArticle => 'Article';

  @override
  String get tagPreposition => 'Preposition';

  @override
  String get tagConjunction => 'Conjunction';

  @override
  String get tagModalVerb => 'Modal verb';

  @override
  String get tagSeparableVerb => 'Separable verb';

  @override
  String get tagReflexiveVerb => 'Reflexive verb';

  @override
  String get tagIrregularVerb => 'Irregular verb';

  @override
  String get tagQuestionWord => 'Question word';

  @override
  String get tagNegation => 'Negation';

  @override
  String get tagNumbers => 'Numbers';

  @override
  String get tagTimeExpression => 'Time expression';

  @override
  String get tagPlaceExpression => 'Place expression';

  @override
  String get tagProperNoun => 'Proper noun';

  @override
  String get tagLoanwordInternational => 'Loanword (international)';

  @override
  String get tagAbbreviation => 'Abbreviation';

  @override
  String get tagUncategorized => 'Uncategorized';
}
