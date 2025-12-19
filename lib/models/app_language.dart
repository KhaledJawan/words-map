import 'package:flutter/widgets.dart';

enum AppLanguage {
  en,
  fa,
  ps,
}

extension AppLanguageExtension on AppLanguage {
  String get languageCode {
    switch (this) {
      case AppLanguage.fa:
        return 'fa';
      case AppLanguage.ps:
        return 'ps';
      case AppLanguage.en:
        return 'en';
    }
  }

  Locale get locale => Locale(languageCode);

  /// Always show language names in their native form so users can recover
  /// after accidentally switching languages.
  String get nativeName {
    switch (this) {
      case AppLanguage.en:
        return 'English';
      case AppLanguage.fa:
        return 'فارسی';
      case AppLanguage.ps:
        return 'پښتو';
    }
  }
}

AppLanguage appLanguageFromLocale(String? code) {
  switch (code) {
    case 'fa':
      return AppLanguage.fa;
    case 'ps':
      return AppLanguage.ps;
    case 'en':
    case 'de': // legacy
    default:
      return AppLanguage.en;
  }
}
