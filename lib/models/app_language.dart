import 'package:flutter/widgets.dart';

enum AppLanguage { de, en, fa, ps, tr, fr }

extension AppLanguageExtension on AppLanguage {
  String get languageCode {
    switch (this) {
      case AppLanguage.de:
        return 'de';
      case AppLanguage.fa:
        return 'fa';
      case AppLanguage.ps:
        return 'ps';
      case AppLanguage.tr:
        return 'tr';
      case AppLanguage.fr:
        return 'fr';
      case AppLanguage.en:
        return 'en';
    }
  }

  Locale get locale => Locale(languageCode);

  /// Always show language names in their native form so users can recover
  /// after accidentally switching languages.
  String get nativeName {
    switch (this) {
      case AppLanguage.de:
        return 'Deutsch';
      case AppLanguage.en:
        return 'English';
      case AppLanguage.fa:
        return 'فارسی';
      case AppLanguage.ps:
        return 'پښتو';
      case AppLanguage.tr:
        return 'Türkçe';
      case AppLanguage.fr:
        return 'Français';
    }
  }

  bool get isRtlScript {
    switch (this) {
      case AppLanguage.fa:
      case AppLanguage.ps:
        return true;
      case AppLanguage.de:
      case AppLanguage.en:
      case AppLanguage.tr:
      case AppLanguage.fr:
        return false;
    }
  }
}

AppLanguage appLanguageFromLocale(String? code) {
  switch (code) {
    case 'fa':
      return AppLanguage.fa;
    case 'ps':
      return AppLanguage.ps;
    case 'tr':
      return AppLanguage.tr;
    case 'fr':
      return AppLanguage.fr;
    case 'en':
    default:
      return AppLanguage.en;
  }
}

AppLanguage wordLanguageFromCode(String? code) {
  switch (code) {
    case 'de':
      return AppLanguage.de;
    case 'fa':
      return AppLanguage.fa;
    case 'ps':
      return AppLanguage.ps;
    case 'tr':
      return AppLanguage.tr;
    case 'fr':
      return AppLanguage.fr;
    case 'en':
    default:
      return AppLanguage.en;
  }
}
