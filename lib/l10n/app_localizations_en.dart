// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Word Map';

  @override
  String wordMapTitleWithLevel(Object level) {
    return '$level Words';
  }

  @override
  String get barrierWordDetails => 'Word details';

  @override
  String get dialogExampleHeading => 'Example';

  @override
  String get dialogExampleMissing => 'No example yet';

  @override
  String get dialogExampleTranslationMissing => 'No translated example';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsChangeLanguage => 'Change Language';

  @override
  String get settingsChangeTheme => 'Change Theme';

  @override
  String get settingsSignOut => 'Sign out / Sign in';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageFarsi => 'فارسی';

  @override
  String get settingsThemeLight => 'Light Mode';

  @override
  String get settingsThemeDark => 'Dark Mode';

  @override
  String get settingsSignOutConfirmTitle => 'Sign out?';

  @override
  String get settingsSignOutConfirmMessage => 'Are you sure you want to sign out?';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get settingsSignOutAction => 'Sign out';

  @override
  String get wordLevelsTitle => 'Word Levels';

  @override
  String get onboardingTitle => 'Welcome to Word Map';

  @override
  String get onboardingSubtitle => 'Set your language to personalize translations.';

  @override
  String get onboardingMyLanguage => 'My language';

  @override
  String get onboardingSelectLanguage => 'Select your language';

  @override
  String get onboardingILearn => 'I learn';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingChangeLater => 'You can change this later in settings.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageFarsi => 'فارسی';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageFrench => 'French';

  @override
  String get languageTurkish => 'Turkish';

  @override
  String get learningLanguageGerman => 'Deutsch';

  @override
  String get settingsSelectLanguageTitle => 'Select language';

  @override
  String get settingsSelectThemeTitle => 'Select theme';

  @override
  String get settingsSignOutSuccess => 'Signed out';

  @override
  String settingsSignOutFailed(String error) {
    return 'Sign out failed: $error';
  }

  @override
  String get authConnectTitle => 'Connect your account';

  @override
  String get authSignInSubtitle => 'Sign in to sync and recover your progress across devices.';

  @override
  String get authOptionalNote => 'You can keep using Word Map without signing in. Connecting keeps your progress backed up.';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authOrSeparator => 'OR';

  @override
  String get authSignInWithEmail => 'Sign in with email';

  @override
  String get authSignInWithApple => 'Sign in with Apple';

  @override
  String get authNoAccountCta => 'Don’t have an account? Sign up';

  @override
  String get loginSkipTitle => 'Get started';

  @override
  String get loginSkipSubtitle => 'Sign in to sync progress, or continue without an account.';

  @override
  String get loginSkipLogin => 'Log in / Sign up';

  @override
  String get loginSkipContinue => 'Continue without account';

  @override
  String get loginComingSoonTitle => 'Login coming soon';

  @override
  String get loginComingSoonSubtitle => 'We are building authentication. Continue without an account for now.';

  @override
  String get loginComingSoonGoToMap => 'Go to Word Map';

  @override
  String get loadWordsFailed => 'Couldn’t load words';

  @override
  String get chapterEmptyState => 'No words in this chapter yet.';

  @override
  String get profileTitle => 'Profile & settings';

  @override
  String get sortWords => 'Sort words';

  @override
  String get resetChapter => 'Reset this chapter';

  @override
  String chapterOverview(String chapter) {
    return 'Chapter $chapter overview';
  }

  @override
  String get totalWordsLabel => 'Total words';

  @override
  String get bookmarkedLabel => 'Bookmarked';

  @override
  String get viewedLabel => 'Viewed';

  @override
  String chapterReset(String chapter) {
    return 'Chapter $chapter reset';
  }

  @override
  String get chooseChapter => 'Choose your chapter';

  @override
  String get wordDetailsHeading => 'Word details';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignUp => 'Sign up';

  @override
  String get authSignInWithGoogle => 'Sign in with Google';
}
