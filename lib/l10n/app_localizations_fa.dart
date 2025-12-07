// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'نقشهٔ لغات';

  @override
  String wordMapTitleWithLevel(Object level) {
    return 'لغات $level';
  }

  @override
  String get barrierWordDetails => 'جزئیات لغت';

  @override
  String get dialogExampleHeading => 'مثال';

  @override
  String get dialogExampleMissing => 'مثالی ثبت نشده است';

  @override
  String get dialogExampleTranslationMissing => 'ترجمه‌ای برای مثال نیست';

  @override
  String get settingsTitle => 'تنظیمات';

  @override
  String get settingsChangeLanguage => 'تغییر زبان';

  @override
  String get settingsChangeTheme => 'تغییر تم';

  @override
  String get settingsSignOut => 'خروج / ورود';

  @override
  String get settingsLanguageEnglish => 'انگلیسی';

  @override
  String get settingsLanguageFarsi => 'فارسی';

  @override
  String get settingsThemeLight => 'حالت روشن';

  @override
  String get settingsThemeDark => 'حالت تاریک';

  @override
  String get settingsSignOutConfirmTitle => 'خروج؟';

  @override
  String get settingsSignOutConfirmMessage => 'آیا از خروج مطمئن هستید؟';

  @override
  String get settingsCancel => 'انصراف';

  @override
  String get settingsSignOutAction => 'خروج';

  @override
  String get wordLevelsTitle => 'سطح‌های لغت';

  @override
  String get onboardingTitle => 'به نقشهٔ لغات خوش آمدید';

  @override
  String get onboardingSubtitle => 'زبان خود را انتخاب کنید تا ترجمه‌ها بر همان اساس تنظیم شوند.';

  @override
  String get onboardingMyLanguage => 'زبان من';

  @override
  String get onboardingSelectLanguage => 'زبان خود را انتخاب کنید';

  @override
  String get onboardingILearn => 'زبان در حال یادگیری';

  @override
  String get onboardingContinue => 'ادامه';

  @override
  String get onboardingChangeLater => 'بعداً از تنظیمات می‌توانید عوض کنید.';

  @override
  String get languageEnglish => 'انگلیسی';

  @override
  String get languageGerman => 'آلمانی';

  @override
  String get languageFarsi => 'فارسی';

  @override
  String get languageArabic => 'عربی';

  @override
  String get languageSpanish => 'اسپانیایی';

  @override
  String get languageFrench => 'فرانسوی';

  @override
  String get languageTurkish => 'ترکی استانبولی';

  @override
  String get learningLanguageGerman => 'آلمانی';

  @override
  String get settingsSelectLanguageTitle => 'انتخاب زبان';

  @override
  String get settingsSelectThemeTitle => 'انتخاب تم';

  @override
  String get settingsSignOutSuccess => 'خروج انجام شد';

  @override
  String settingsSignOutFailed(String error) {
    return 'خروج انجام نشد: $error';
  }

  @override
  String get authConnectTitle => 'حساب خود را وصل کنید';

  @override
  String get authSignInSubtitle => 'برای همگام‌سازی و بازیابی پیشرفت خود بین دستگاه‌ها وارد شوید.';

  @override
  String get authOptionalNote => 'بدون ورود هم می‌توانید از نقشهٔ لغات استفاده کنید؛ با اتصال حساب، پیشرفت شما ذخیره و پشتیبان می‌شود.';

  @override
  String get authForgotPassword => 'رمز عبور را فراموش کرده‌اید؟';

  @override
  String get authOrSeparator => 'یا';

  @override
  String get authSignInWithEmail => 'ورود با ایمیل';

  @override
  String get authSignInWithApple => 'ورود با اپل';

  @override
  String get authNoAccountCta => 'حساب ندارید؟ ثبت‌نام کنید';

  @override
  String get loginSkipTitle => 'شروع کنیم';

  @override
  String get loginSkipSubtitle => 'برای همگام‌سازی وارد شوید یا بدون حساب ادامه دهید.';

  @override
  String get loginSkipLogin => 'ورود / ثبت‌نام';

  @override
  String get loginSkipContinue => 'ادامه بدون حساب';

  @override
  String get loginComingSoonTitle => 'ورود به‌زودی';

  @override
  String get loginComingSoonSubtitle => 'بخش ورود در حال ساخت است؛ فعلاً بدون حساب ادامه دهید.';

  @override
  String get loginComingSoonGoToMap => 'رفتن به نقشهٔ لغات';

  @override
  String get loadWordsFailed => 'بارگذاری لغات انجام نشد';

  @override
  String get chapterEmptyState => 'در این فصل هنوز لغتی نیست.';

  @override
  String get profileTitle => 'پروفایل و تنظیمات';

  @override
  String get sortWords => 'مرتب‌سازی لغات';

  @override
  String get resetChapter => 'بارگذاری دوباره فصل';

  @override
  String chapterOverview(String chapter) {
    return 'نمای کلی فصل $chapter';
  }

  @override
  String get totalWordsLabel => 'تعداد لغات';

  @override
  String get bookmarkedLabel => 'نشان‌شده';

  @override
  String get viewedLabel => 'دیده‌شده';

  @override
  String chapterReset(String chapter) {
    return 'فصل $chapter دوباره بارگذاری شد';
  }

  @override
  String get chooseChapter => 'فصل خود را انتخاب کنید';

  @override
  String get wordDetailsHeading => 'جزئیات واژه';

  @override
  String get authEmail => 'ایمیل';

  @override
  String get authPassword => 'رمز عبور';

  @override
  String get authSignIn => 'ورود';

  @override
  String get authSignUp => 'ثبت‌نام';

  @override
  String get authSignInWithGoogle => 'ورود با گوگل';
}
