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
  }
}

List<String> getLocalizedExamples(AlphabetLessonItem item, AppLanguage language) {
  switch (language) {
    case AppLanguage.fa:
      return item.examplesFa;
    case AppLanguage.ps:
      return item.examplesFa.isNotEmpty ? item.examplesFa : item.examplesEn;
    case AppLanguage.en:
      return item.examplesEn;
  }
}
