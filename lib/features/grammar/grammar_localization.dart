import 'package:word_map_app/models/app_language.dart';
import 'package:word_map_app/features/grammar/grammar_models.dart';

String localizedGrammarTopicTitle(GrammarTopic topic, AppLanguage lang) {
  switch (lang) {
    case AppLanguage.fa:
      return topic.titleFa.isNotEmpty ? topic.titleFa : (topic.titleEn.isNotEmpty ? topic.titleEn : topic.titleDe);
    case AppLanguage.en:
      return topic.titleEn.isNotEmpty ? topic.titleEn : (topic.titleDe.isNotEmpty ? topic.titleDe : topic.titleFa);
    case AppLanguage.de:
      return topic.titleDe.isNotEmpty ? topic.titleDe : (topic.titleEn.isNotEmpty ? topic.titleEn : topic.titleFa);
  }
}

String localizedGrammarTopicDescription(GrammarTopic topic, AppLanguage lang) {
  switch (lang) {
    case AppLanguage.fa:
      return topic.descriptionFa.isNotEmpty
          ? topic.descriptionFa
          : (topic.descriptionEn.isNotEmpty ? topic.descriptionEn : topic.descriptionDe);
    case AppLanguage.en:
      return topic.descriptionEn.isNotEmpty
          ? topic.descriptionEn
          : (topic.descriptionDe.isNotEmpty ? topic.descriptionDe : topic.descriptionFa);
    case AppLanguage.de:
      return topic.descriptionDe.isNotEmpty
          ? topic.descriptionDe
          : (topic.descriptionEn.isNotEmpty ? topic.descriptionEn : topic.descriptionFa);
  }
}
