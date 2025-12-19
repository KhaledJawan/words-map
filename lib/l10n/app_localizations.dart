import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_ps.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa'),
    Locale('ps')
  ];

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsChangeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get settingsChangeLanguage;

  /// No description provided for @settingsAppLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsAppLanguageTitle;

  /// No description provided for @settingsWordLanguagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Word language(s)'**
  String get settingsWordLanguagesTitle;

  /// No description provided for @settingsSelectWordLanguagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Word languages'**
  String get settingsSelectWordLanguagesTitle;

  /// No description provided for @settingsSelectWordLanguagesHint.
  ///
  /// In en, this message translates to:
  /// **'Choose 1 or 2'**
  String get settingsSelectWordLanguagesHint;

  /// No description provided for @settingsWordLanguagesMaxTwo.
  ///
  /// In en, this message translates to:
  /// **'You can select up to 2 languages.'**
  String get settingsWordLanguagesMaxTwo;

  /// No description provided for @settingsWordLanguagesMinOne.
  ///
  /// In en, this message translates to:
  /// **'Select at least one language.'**
  String get settingsWordLanguagesMinOne;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabLessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get tabLessons;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @totalWordsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total words'**
  String get totalWordsLabel;

  /// No description provided for @settingsLanguageFarsi.
  ///
  /// In en, this message translates to:
  /// **'فارسی'**
  String get settingsLanguageFarsi;

  /// No description provided for @settingsLanguagePashto.
  ///
  /// In en, this message translates to:
  /// **'پښتو'**
  String get settingsLanguagePashto;

  /// No description provided for @loadWordsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load words.'**
  String get loadWordsFailed;

  /// No description provided for @settingsSelectLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get settingsSelectLanguageTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'App interface language'**
  String get settingsLanguageDescription;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose app appearance'**
  String get settingsThemeDescription;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get settingsThemeDark;

  /// No description provided for @settingsNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications & Reminders'**
  String get settingsNotificationsTitle;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'App notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'App alerts and daily check-ins'**
  String get settingsNotificationsDescription;

  /// No description provided for @settingsDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get settingsDailyReminder;

  /// No description provided for @lessonsTitle.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessonsTitle;

  /// No description provided for @lessonBeginnerAlphabetTitle.
  ///
  /// In en, this message translates to:
  /// **'Alphabet'**
  String get lessonBeginnerAlphabetTitle;

  /// No description provided for @lessonBeginnerReadingRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading rules'**
  String get lessonBeginnerReadingRulesTitle;

  /// No description provided for @lessonBeginnerPartsOfSpeechTitle.
  ///
  /// In en, this message translates to:
  /// **'Parts of speech'**
  String get lessonBeginnerPartsOfSpeechTitle;

  /// No description provided for @lessonBeginnerHalloTitle.
  ///
  /// In en, this message translates to:
  /// **'Hallo'**
  String get lessonBeginnerHalloTitle;

  /// No description provided for @lessonBeginnerAllAboutGermanTitle.
  ///
  /// In en, this message translates to:
  /// **'All about German'**
  String get lessonBeginnerAllAboutGermanTitle;

  /// No description provided for @lessonsCategoryBeginnerBasics.
  ///
  /// In en, this message translates to:
  /// **'Beginner Basics'**
  String get lessonsCategoryBeginnerBasics;

  /// No description provided for @lessonsCategoryGrammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get lessonsCategoryGrammar;

  /// No description provided for @lessonsCategoryReadingListening.
  ///
  /// In en, this message translates to:
  /// **'Reading & Listening'**
  String get lessonsCategoryReadingListening;

  /// No description provided for @lessonsCategoryExamPractice.
  ///
  /// In en, this message translates to:
  /// **'Exam Practice'**
  String get lessonsCategoryExamPractice;

  /// No description provided for @grammarLevelA1.
  ///
  /// In en, this message translates to:
  /// **'A1 Grammar'**
  String get grammarLevelA1;

  /// No description provided for @grammarLevelA2.
  ///
  /// In en, this message translates to:
  /// **'A2 Grammar'**
  String get grammarLevelA2;

  /// No description provided for @grammarLevelB1.
  ///
  /// In en, this message translates to:
  /// **'B1 Grammar'**
  String get grammarLevelB1;

  /// No description provided for @grammarLevelB2.
  ///
  /// In en, this message translates to:
  /// **'B2 Grammar'**
  String get grammarLevelB2;

  /// No description provided for @grammarLevelC1.
  ///
  /// In en, this message translates to:
  /// **'C1 Grammar'**
  String get grammarLevelC1;

  /// No description provided for @grammarLevelLessonsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No lessons yet} =1{1 lesson} other{{count} lessons}}'**
  String grammarLevelLessonsCount(num count);

  /// No description provided for @lessonsStatusComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get lessonsStatusComingSoon;

  /// No description provided for @grammarContentLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load grammar content.'**
  String get grammarContentLoadError;

  /// No description provided for @lessonExamplesTitle.
  ///
  /// In en, this message translates to:
  /// **'Examples'**
  String get lessonExamplesTitle;

  /// No description provided for @grammarTopicComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Content will be added later.'**
  String get grammarTopicComingSoon;

  /// No description provided for @lessonButtonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get lessonButtonNext;

  /// No description provided for @slideAlphabetOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'German Alphabet – Overview'**
  String get slideAlphabetOverviewTitle;

  /// No description provided for @slideAlphabetVowelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Vowels (A, E, I, O, U)'**
  String get slideAlphabetVowelsTitle;

  /// No description provided for @slideAlphabetUmlautTitle.
  ///
  /// In en, this message translates to:
  /// **'Umlaut vowels (Ä, Ö, Ü)'**
  String get slideAlphabetUmlautTitle;

  /// No description provided for @slideAlphabetEsszettTitle.
  ///
  /// In en, this message translates to:
  /// **'ß – Eszett'**
  String get slideAlphabetEsszettTitle;

  /// No description provided for @slideReadingBasicRuleTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic reading rule – “ie” vs “ei”'**
  String get slideReadingBasicRuleTitle;

  /// No description provided for @slideReadingSchChSpStTitle.
  ///
  /// In en, this message translates to:
  /// **'“sch”, “ch” and “sp / st”'**
  String get slideReadingSchChSpStTitle;

  /// No description provided for @slideReadingCapitalLettersTitle.
  ///
  /// In en, this message translates to:
  /// **'Capital letters (Nouns)'**
  String get slideReadingCapitalLettersTitle;

  /// No description provided for @slideReadingLongVsShortTitle.
  ///
  /// In en, this message translates to:
  /// **'Long vs short vowels'**
  String get slideReadingLongVsShortTitle;

  /// No description provided for @slidePartsMainPartsTitle.
  ///
  /// In en, this message translates to:
  /// **'Main parts of speech'**
  String get slidePartsMainPartsTitle;

  /// No description provided for @slidePartsNounsGenderTitle.
  ///
  /// In en, this message translates to:
  /// **'Nouns and gender'**
  String get slidePartsNounsGenderTitle;

  /// No description provided for @slidePartsVerbsInfinitiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Verbs in basic form (Infinitiv)'**
  String get slidePartsVerbsInfinitiveTitle;

  /// No description provided for @slidePartsAdjectivesTitle.
  ///
  /// In en, this message translates to:
  /// **'Adjectives – describing words'**
  String get slidePartsAdjectivesTitle;

  /// No description provided for @slideHalloBasicGreetingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic greetings'**
  String get slideHalloBasicGreetingsTitle;

  /// No description provided for @slideHalloIntroducingTitle.
  ///
  /// In en, this message translates to:
  /// **'Introducing yourself'**
  String get slideHalloIntroducingTitle;

  /// No description provided for @slideHalloHowAreYouTitle.
  ///
  /// In en, this message translates to:
  /// **'Asking “How are you?”'**
  String get slideHalloHowAreYouTitle;

  /// No description provided for @slideHalloPoliteWordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Polite words'**
  String get slideHalloPoliteWordsTitle;

  /// No description provided for @slideGermanWhereSpokenTitle.
  ///
  /// In en, this message translates to:
  /// **'Where is German spoken?'**
  String get slideGermanWhereSpokenTitle;

  /// No description provided for @slideGermanFormalInformalTitle.
  ///
  /// In en, this message translates to:
  /// **'Formal vs informal “you”'**
  String get slideGermanFormalInformalTitle;

  /// No description provided for @slideGermanWordOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Word order – basic idea'**
  String get slideGermanWordOrderTitle;

  /// No description provided for @slideGermanLongWordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Don’t be afraid of long words'**
  String get slideGermanLongWordsTitle;

  /// No description provided for @chapterOverview.
  ///
  /// In en, this message translates to:
  /// **'Chapter {chapter} overview'**
  String chapterOverview(Object chapter);

  /// No description provided for @chooseChapter.
  ///
  /// In en, this message translates to:
  /// **'Choose your chapter'**
  String get chooseChapter;

  /// No description provided for @chapterEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No words in this chapter yet.'**
  String get chapterEmptyState;

  /// No description provided for @bookmarkedLabel.
  ///
  /// In en, this message translates to:
  /// **'Bookmarked'**
  String get bookmarkedLabel;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @viewedLabel.
  ///
  /// In en, this message translates to:
  /// **'Viewed'**
  String get viewedLabel;

  /// No description provided for @lessonCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get lessonCompleted;

  /// No description provided for @lessonRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get lessonRepeat;

  /// No description provided for @lessonRepeatAgain.
  ///
  /// In en, this message translates to:
  /// **'Repeat again'**
  String get lessonRepeatAgain;

  /// No description provided for @chapterCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get chapterCategories;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get chooseCategory;

  /// No description provided for @categoryEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No words in this category yet.'**
  String get categoryEmptyState;

  /// No description provided for @categoryOverview.
  ///
  /// In en, this message translates to:
  /// **'Category {category} overview'**
  String categoryOverview(Object category);

  /// No description provided for @homeSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'☕️ Support WordMap'**
  String get homeSupportTitle;

  /// No description provided for @homeSupportBody.
  ///
  /// In en, this message translates to:
  /// **'German got you like… 🤯?\nTap 💎 to keep the tea brewing ☕️❤️'**
  String get homeSupportBody;

  /// No description provided for @homeSupportSupportButton.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get homeSupportSupportButton;

  /// No description provided for @homeSupportCloseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get homeSupportCloseTooltip;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonLesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get commonLesson;

  /// No description provided for @lessonLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load lesson.'**
  String get lessonLoadFailed;

  /// No description provided for @audioPlaybackFailed.
  ///
  /// In en, this message translates to:
  /// **'Audio couldn’t be played.'**
  String get audioPlaybackFailed;

  /// No description provided for @adLoading.
  ///
  /// In en, this message translates to:
  /// **'Ad is loading…'**
  String get adLoading;

  /// No description provided for @noMoreWordsTitle.
  ///
  /// In en, this message translates to:
  /// **'No more words'**
  String get noMoreWordsTitle;

  /// No description provided for @noMoreWordsBody.
  ///
  /// In en, this message translates to:
  /// **'You reached 0. Watch an ad to activate 💎 mode for 1 hour (unlimited words), or wait 1 hour to get 50 words back.'**
  String get noMoreWordsBody;

  /// No description provided for @noMoreWordsWaitOneHour.
  ///
  /// In en, this message translates to:
  /// **'Wait 1 hour'**
  String get noMoreWordsWaitOneHour;

  /// No description provided for @noMoreWordsWatchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch ad'**
  String get noMoreWordsWatchAd;

  /// No description provided for @diamondBadgeSubtitleActive.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get diamondBadgeSubtitleActive;

  /// No description provided for @diamondBadgeSubtitleInactive.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get diamondBadgeSubtitleInactive;

  /// No description provided for @diamondBadgeSubtitleCooldown.
  ///
  /// In en, this message translates to:
  /// **'Cooldown'**
  String get diamondBadgeSubtitleCooldown;

  /// No description provided for @cooldownActive.
  ///
  /// In en, this message translates to:
  /// **'Try again in {time}'**
  String cooldownActive(Object time);

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'New version available'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'Please update WordMap to get the latest features.'**
  String get updateAvailableBody;

  /// No description provided for @updateAvailableLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateAvailableLater;

  /// No description provided for @updateAvailableUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateAvailableUpdate;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error: {error}'**
  String authError(Object error);

  /// No description provided for @tagA1Core.
  ///
  /// In en, this message translates to:
  /// **'A1 core'**
  String get tagA1Core;

  /// No description provided for @tagDailyLife.
  ///
  /// In en, this message translates to:
  /// **'Daily life'**
  String get tagDailyLife;

  /// No description provided for @tagConversationPhrases.
  ///
  /// In en, this message translates to:
  /// **'Conversation phrases'**
  String get tagConversationPhrases;

  /// No description provided for @tagGreetingsPoliteness.
  ///
  /// In en, this message translates to:
  /// **'Greetings & politeness'**
  String get tagGreetingsPoliteness;

  /// No description provided for @tagQuestionsAnswers.
  ///
  /// In en, this message translates to:
  /// **'Questions & answers'**
  String get tagQuestionsAnswers;

  /// No description provided for @tagTimeDate.
  ///
  /// In en, this message translates to:
  /// **'Time & date'**
  String get tagTimeDate;

  /// No description provided for @tagNumbersMath.
  ///
  /// In en, this message translates to:
  /// **'Numbers & math'**
  String get tagNumbersMath;

  /// No description provided for @tagColorsShapes.
  ///
  /// In en, this message translates to:
  /// **'Colors & shapes'**
  String get tagColorsShapes;

  /// No description provided for @tagDaysMonthsSeasons.
  ///
  /// In en, this message translates to:
  /// **'Days, months & seasons'**
  String get tagDaysMonthsSeasons;

  /// No description provided for @tagWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get tagWeather;

  /// No description provided for @tagDirectionsNavigation.
  ///
  /// In en, this message translates to:
  /// **'Directions & navigation'**
  String get tagDirectionsNavigation;

  /// No description provided for @tagPlacesBuildings.
  ///
  /// In en, this message translates to:
  /// **'Places & buildings'**
  String get tagPlacesBuildings;

  /// No description provided for @tagCityTransport.
  ///
  /// In en, this message translates to:
  /// **'City & transport'**
  String get tagCityTransport;

  /// No description provided for @tagTravelHolidays.
  ///
  /// In en, this message translates to:
  /// **'Travel & holidays'**
  String get tagTravelHolidays;

  /// No description provided for @tagHomeHousehold.
  ///
  /// In en, this message translates to:
  /// **'Home & household'**
  String get tagHomeHousehold;

  /// No description provided for @tagFurnitureRooms.
  ///
  /// In en, this message translates to:
  /// **'Furniture & rooms'**
  String get tagFurnitureRooms;

  /// No description provided for @tagKitchenCooking.
  ///
  /// In en, this message translates to:
  /// **'Kitchen & cooking'**
  String get tagKitchenCooking;

  /// No description provided for @tagFoodDrink.
  ///
  /// In en, this message translates to:
  /// **'Food & drink'**
  String get tagFoodDrink;

  /// No description provided for @tagShoppingMoney.
  ///
  /// In en, this message translates to:
  /// **'Shopping & money'**
  String get tagShoppingMoney;

  /// No description provided for @tagClothingFashion.
  ///
  /// In en, this message translates to:
  /// **'Clothing & fashion'**
  String get tagClothingFashion;

  /// No description provided for @tagHealthBody.
  ///
  /// In en, this message translates to:
  /// **'Health & body'**
  String get tagHealthBody;

  /// No description provided for @tagFeelingsEmotions.
  ///
  /// In en, this message translates to:
  /// **'Feelings & emotions'**
  String get tagFeelingsEmotions;

  /// No description provided for @tagPeopleFamily.
  ///
  /// In en, this message translates to:
  /// **'People & family'**
  String get tagPeopleFamily;

  /// No description provided for @tagRelationships.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get tagRelationships;

  /// No description provided for @tagSchoolLearning.
  ///
  /// In en, this message translates to:
  /// **'School & learning'**
  String get tagSchoolLearning;

  /// No description provided for @tagWorkOffice.
  ///
  /// In en, this message translates to:
  /// **'Work & office'**
  String get tagWorkOffice;

  /// No description provided for @tagJobsProfessions.
  ///
  /// In en, this message translates to:
  /// **'Jobs & professions'**
  String get tagJobsProfessions;

  /// No description provided for @tagTechnologyInternet.
  ///
  /// In en, this message translates to:
  /// **'Technology & internet'**
  String get tagTechnologyInternet;

  /// No description provided for @tagMediaSocial.
  ///
  /// In en, this message translates to:
  /// **'Media & social'**
  String get tagMediaSocial;

  /// No description provided for @tagHobbiesSports.
  ///
  /// In en, this message translates to:
  /// **'Hobbies & sports'**
  String get tagHobbiesSports;

  /// No description provided for @tagNatureAnimals.
  ///
  /// In en, this message translates to:
  /// **'Nature & animals'**
  String get tagNatureAnimals;

  /// No description provided for @tagPlantsEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Plants & environment'**
  String get tagPlantsEnvironment;

  /// No description provided for @tagCultureEvents.
  ///
  /// In en, this message translates to:
  /// **'Culture & events'**
  String get tagCultureEvents;

  /// No description provided for @tagServicesAuthorities.
  ///
  /// In en, this message translates to:
  /// **'Services & authorities'**
  String get tagServicesAuthorities;

  /// No description provided for @tagReligionCulture.
  ///
  /// In en, this message translates to:
  /// **'Religion & culture'**
  String get tagReligionCulture;

  /// No description provided for @tagSafetyEmergency.
  ///
  /// In en, this message translates to:
  /// **'Safety & emergency'**
  String get tagSafetyEmergency;

  /// No description provided for @tagLawRules.
  ///
  /// In en, this message translates to:
  /// **'Law & rules'**
  String get tagLawRules;

  /// No description provided for @tagVerb.
  ///
  /// In en, this message translates to:
  /// **'Verb'**
  String get tagVerb;

  /// No description provided for @tagNoun.
  ///
  /// In en, this message translates to:
  /// **'Noun'**
  String get tagNoun;

  /// No description provided for @tagAdjective.
  ///
  /// In en, this message translates to:
  /// **'Adjective'**
  String get tagAdjective;

  /// No description provided for @tagAdverb.
  ///
  /// In en, this message translates to:
  /// **'Adverb'**
  String get tagAdverb;

  /// No description provided for @tagPronoun.
  ///
  /// In en, this message translates to:
  /// **'Pronoun'**
  String get tagPronoun;

  /// No description provided for @tagArticle.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get tagArticle;

  /// No description provided for @tagPreposition.
  ///
  /// In en, this message translates to:
  /// **'Preposition'**
  String get tagPreposition;

  /// No description provided for @tagConjunction.
  ///
  /// In en, this message translates to:
  /// **'Conjunction'**
  String get tagConjunction;

  /// No description provided for @tagModalVerb.
  ///
  /// In en, this message translates to:
  /// **'Modal verb'**
  String get tagModalVerb;

  /// No description provided for @tagSeparableVerb.
  ///
  /// In en, this message translates to:
  /// **'Separable verb'**
  String get tagSeparableVerb;

  /// No description provided for @tagReflexiveVerb.
  ///
  /// In en, this message translates to:
  /// **'Reflexive verb'**
  String get tagReflexiveVerb;

  /// No description provided for @tagIrregularVerb.
  ///
  /// In en, this message translates to:
  /// **'Irregular verb'**
  String get tagIrregularVerb;

  /// No description provided for @tagQuestionWord.
  ///
  /// In en, this message translates to:
  /// **'Question word'**
  String get tagQuestionWord;

  /// No description provided for @tagNegation.
  ///
  /// In en, this message translates to:
  /// **'Negation'**
  String get tagNegation;

  /// No description provided for @tagNumbers.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get tagNumbers;

  /// No description provided for @tagTimeExpression.
  ///
  /// In en, this message translates to:
  /// **'Time expression'**
  String get tagTimeExpression;

  /// No description provided for @tagPlaceExpression.
  ///
  /// In en, this message translates to:
  /// **'Place expression'**
  String get tagPlaceExpression;

  /// No description provided for @tagProperNoun.
  ///
  /// In en, this message translates to:
  /// **'Proper noun'**
  String get tagProperNoun;

  /// No description provided for @tagLoanwordInternational.
  ///
  /// In en, this message translates to:
  /// **'Loanword (international)'**
  String get tagLoanwordInternational;

  /// No description provided for @tagAbbreviation.
  ///
  /// In en, this message translates to:
  /// **'Abbreviation'**
  String get tagAbbreviation;

  /// No description provided for @tagUncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get tagUncategorized;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fa', 'ps'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fa': return AppLocalizationsFa();
    case 'ps': return AppLocalizationsPs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
