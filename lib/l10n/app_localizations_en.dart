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
