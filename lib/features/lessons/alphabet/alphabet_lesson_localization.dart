import 'package:word_map_app/models/app_language.dart';

import 'alphabet_lesson_item.dart';

String getLocalizedSubject(AlphabetLessonItem item, AppLanguage language) {
  switch (language) {
    case AppLanguage.fa:
      return item.subjectFa;
    case AppLanguage.ps:
      return item.subjectFa.isNotEmpty
          ? item.subjectFa
          : (item.subjectEn.isNotEmpty ? item.subjectEn : item.subjectDe);
    case AppLanguage.en:
      return item.subjectEn;
    case AppLanguage.fr:
      return item.subjectEn.isNotEmpty
          ? item.subjectEn
          : (item.subjectDe.isNotEmpty ? item.subjectDe : item.subjectFa);
    case AppLanguage.tr:
      return item.subjectEn.isNotEmpty
          ? item.subjectEn
          : (item.subjectDe.isNotEmpty ? item.subjectDe : item.subjectFa);
    case AppLanguage.de:
      return item.subjectDe.isNotEmpty
          ? item.subjectDe
          : (item.subjectEn.isNotEmpty ? item.subjectEn : item.subjectFa);
  }
}

String getLocalizedDescription(AlphabetLessonItem item, AppLanguage language) {
  switch (language) {
    case AppLanguage.fa:
      return item.descriptionFa;
    case AppLanguage.ps:
      return item.descriptionFa.isNotEmpty
          ? item.descriptionFa
          : item.descriptionEn;
    case AppLanguage.en:
      return item.descriptionEn;
    case AppLanguage.fr:
      return item.descriptionEn.isNotEmpty
          ? item.descriptionEn
          : item.descriptionFa;
    case AppLanguage.tr:
      return item.descriptionEn.isNotEmpty
          ? item.descriptionEn
          : item.descriptionFa;
    case AppLanguage.de:
      return item.descriptionEn.isNotEmpty
          ? item.descriptionEn
          : item.descriptionFa;
  }
}

List<String> getLocalizedExamples(
  AlphabetLessonItem item,
  AppLanguage language,
) {
  switch (language) {
    case AppLanguage.fa:
      return item.examplesFa;
    case AppLanguage.ps:
      return item.examplesFa.isNotEmpty ? item.examplesFa : item.examplesEn;
    case AppLanguage.en:
      return item.examplesEn;
    case AppLanguage.fr:
      return item.examplesEn.isNotEmpty ? item.examplesEn : item.examplesFa;
    case AppLanguage.tr:
      return item.examplesEn.isNotEmpty ? item.examplesEn : item.examplesFa;
    case AppLanguage.de:
      return item.examplesEn.isNotEmpty ? item.examplesEn : item.examplesFa;
  }
}
