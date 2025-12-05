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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Word Map'**
  String get appTitle;

  /// No description provided for @wordMapTitleWithLevel.
  ///
  /// In en, this message translates to:
  /// **'{level} Words'**
  String wordMapTitleWithLevel(Object level);

  /// No description provided for @barrierWordDetails.
  ///
  /// In en, this message translates to:
  /// **'Word details'**
  String get barrierWordDetails;

  /// No description provided for @dialogExampleHeading.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get dialogExampleHeading;

  /// No description provided for @dialogExampleMissing.
  ///
  /// In en, this message translates to:
  /// **'No example yet'**
  String get dialogExampleMissing;

  /// No description provided for @dialogExampleTranslationMissing.
  ///
  /// In en, this message translates to:
  /// **'No translated example'**
  String get dialogExampleTranslationMissing;

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

  /// No description provided for @settingsChangeTheme.
  ///
  /// In en, this message translates to:
  /// **'Change Theme'**
  String get settingsChangeTheme;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out / Sign in'**
  String get settingsSignOut;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageFarsi.
  ///
  /// In en, this message translates to:
  /// **'فارسی'**
  String get settingsLanguageFarsi;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsThemeDark;

  /// No description provided for @settingsSignOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get settingsSignOutConfirmTitle;

  /// No description provided for @settingsSignOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get settingsSignOutConfirmMessage;

  /// No description provided for @settingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// No description provided for @settingsSignOutAction.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOutAction;

  /// No description provided for @wordLevelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Word Levels'**
  String get wordLevelsTitle;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Word Map'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set your language to personalize translations.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingMyLanguage.
  ///
  /// In en, this message translates to:
  /// **'My language'**
  String get onboardingMyLanguage;

  /// No description provided for @onboardingSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your language'**
  String get onboardingSelectLanguage;

  /// No description provided for @onboardingILearn.
  ///
  /// In en, this message translates to:
  /// **'I learn'**
  String get onboardingILearn;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingChangeLater.
  ///
  /// In en, this message translates to:
  /// **'You can change this later in settings.'**
  String get onboardingChangeLater;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageFarsi.
  ///
  /// In en, this message translates to:
  /// **'فارسی'**
  String get languageFarsi;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get languageTurkish;

  /// No description provided for @learningLanguageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get learningLanguageGerman;

  /// No description provided for @settingsSelectLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get settingsSelectLanguageTitle;

  /// No description provided for @settingsSelectThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select theme'**
  String get settingsSelectThemeTitle;

  /// No description provided for @settingsSignOutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get settingsSignOutSuccess;

  /// No description provided for @settingsSignOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign out failed: {error}'**
  String settingsSignOutFailed(String error);

  /// No description provided for @authConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect your account'**
  String get authConnectTitle;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync and recover your progress across devices.'**
  String get authSignInSubtitle;

  /// No description provided for @authOptionalNote.
  ///
  /// In en, this message translates to:
  /// **'You can keep using Word Map without signing in. Connecting keeps your progress backed up.'**
  String get authOptionalNote;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authOrSeparator.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get authOrSeparator;

  /// No description provided for @authSignInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in with email'**
  String get authSignInWithEmail;

  /// No description provided for @authSignInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get authSignInWithApple;

  /// No description provided for @authNoAccountCta.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account? Sign up'**
  String get authNoAccountCta;

  /// No description provided for @loginSkipTitle.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get loginSkipTitle;

  /// No description provided for @loginSkipSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync progress, or continue without an account.'**
  String get loginSkipSubtitle;

  /// No description provided for @loginSkipLogin.
  ///
  /// In en, this message translates to:
  /// **'Log in / Sign up'**
  String get loginSkipLogin;

  /// No description provided for @loginSkipContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue without account'**
  String get loginSkipContinue;

  /// No description provided for @loginComingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Login coming soon'**
  String get loginComingSoonTitle;

  /// No description provided for @loginComingSoonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We are building authentication. Continue without an account for now.'**
  String get loginComingSoonSubtitle;

  /// No description provided for @loginComingSoonGoToMap.
  ///
  /// In en, this message translates to:
  /// **'Go to Word Map'**
  String get loginComingSoonGoToMap;

  /// No description provided for @wordDetailsHeading.
  ///
  /// In en, this message translates to:
  /// **'Word details'**
  String get wordDetailsHeading;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUp;

  /// No description provided for @authSignInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get authSignInWithGoogle;
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
