// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'نقشه واژه‌ها';

  @override
  String wordMapTitleWithLevel(Object level) {
    return 'واژه‌های $level';
  }

  @override
  String get barrierWordDetails => 'جزئیات واژه';

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
  String get settingsChangeTheme => 'تغییر پوسته';

  @override
  String get settingsSignOut => 'خروج / ورود';

  @override
  String get settingsLanguageEnglish => 'انگلیسی';

  @override
  String get settingsLanguageFarsi => 'فارسی';

  @override
  String get settingsThemeLight => 'حالت روشن';

  @override
  String get settingsThemeDark => 'حالت تیره';

  @override
  String get settingsSignOutConfirmTitle => 'خروج؟';

  @override
  String get settingsSignOutConfirmMessage => 'آیا از خروج مطمئن هستید؟';

  @override
  String get settingsCancel => 'انصراف';

  @override
  String get settingsSignOutAction => 'خروج';

  @override
  String get wordLevelsTitle => 'سطوح واژگان';

  @override
  String get onboardingTitle => 'به نقشه واژه خوش آمدید';

  @override
  String get onboardingSubtitle => 'زبان خود را انتخاب کنید تا ترجمه‌ها شخصی‌سازی شوند.';

  @override
  String get onboardingMyLanguage => 'زبان من';

  @override
  String get onboardingSelectLanguage => 'زبان خود را انتخاب کنید';

  @override
  String get onboardingILearn => 'من یاد می‌گیرم';

  @override
  String get onboardingContinue => 'ادامه';

  @override
  String get onboardingChangeLater => 'بعداً در تنظیمات می‌توانید تغییر دهید.';

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
  String get settingsSelectThemeTitle => 'انتخاب پوسته';

  @override
  String get settingsSignOutSuccess => 'خروج انجام شد';

  @override
  String settingsSignOutFailed(String error) {
    return 'خروج انجام نشد: $error';
  }

  @override
  String get authConnectTitle => 'حساب خود را وصل کنید';

  @override
  String get authSignInSubtitle => 'برای همگام‌سازی و بازیابی پیشرفت خود در دستگاه‌ها وارد شوید.';

  @override
  String get authOptionalNote => 'بدون ورود هم می‌توانید از نقشه واژه استفاده کنید. با اتصال حساب، پیشرفت شما ذخیره و پشتیبان می‌شود.';

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
  String get loginSkipSubtitle => 'وارد شوید تا پیشرفتتان همگام شود یا بدون حساب ادامه دهید.';

  @override
  String get loginSkipLogin => 'ورود / ثبت‌نام';

  @override
  String get loginSkipContinue => 'ادامه بدون حساب';

  @override
  String get loginComingSoonTitle => 'ورود به‌زودی';

  @override
  String get loginComingSoonSubtitle => 'در حال ساخت ورود هستیم. فعلاً بدون حساب ادامه دهید.';

  @override
  String get loginComingSoonGoToMap => 'رفتن به نقشه واژه';

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
