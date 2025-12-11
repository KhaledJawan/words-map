import 'package:flutter/widgets.dart';

enum AppLanguage {
  en,
  fa,
  de,
}

extension AppLanguageExtension on AppLanguage {
  String get languageCode {
    switch (this) {
      case AppLanguage.fa:
        return 'fa';
      case AppLanguage.de:
        return 'de';
      case AppLanguage.en:
        return 'en';
    }
  }

  Locale get locale => Locale(languageCode);
}

AppLanguage appLanguageFromLocale(String? code) {
  switch (code) {
    case 'fa':
      return AppLanguage.fa;
    case 'de':
      return AppLanguage.de;
    case 'en':
    default:
      return AppLanguage.en;
  }
}
