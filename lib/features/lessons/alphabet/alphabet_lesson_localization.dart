import 'package:word_map_app/models/app_language.dart';

import 'alphabet_lesson_item.dart';

String getLocalizedSubject(AlphabetLessonItem item, AppLanguage language) {
  switch (language) {
    case AppLanguage.fa:
      return item.subjectFa;
    case AppLanguage.de:
      return item.subjectDe;
    case AppLanguage.en:
      return item.subjectEn;
  }
}

String getLocalizedDescription(AlphabetLessonItem item, AppLanguage language) {
  switch (language) {
    case AppLanguage.fa:
      return item.descriptionFa;
    case AppLanguage.de:
      return item.descriptionEn;
    case AppLanguage.en:
      return item.descriptionEn;
  }
}

List<String> getLocalizedExamples(AlphabetLessonItem item, AppLanguage language) {
  switch (language) {
    case AppLanguage.fa:
      return item.examplesFa;
    case AppLanguage.de:
    case AppLanguage.en:
      return item.examplesEn;
  }
}
