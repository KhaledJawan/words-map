import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

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
    Locale('fa')
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
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fa': return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
