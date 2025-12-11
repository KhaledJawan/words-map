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
  String get lessonCompleted => 'Completed';

  @override
  String get lessonRepeat => 'Repeat';

  @override
  String get lessonRepeatAgain => 'Repeat again';
}
