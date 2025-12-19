import 'package:word_map_app/models/app_language.dart';
import 'package:word_map_app/features/grammar/grammar_models.dart';

String localizedGrammarTopicTitle(GrammarTopic topic, AppLanguage lang) {
  switch (lang) {
    case AppLanguage.fa:
      return topic.titleFa.isNotEmpty ? topic.titleFa : (topic.titleEn.isNotEmpty ? topic.titleEn : topic.titleDe);
    case AppLanguage.ps:
      return topic.titleFa.isNotEmpty ? topic.titleFa : (topic.titleEn.isNotEmpty ? topic.titleEn : topic.titleDe);
    case AppLanguage.en:
      return topic.titleEn.isNotEmpty ? topic.titleEn : (topic.titleFa.isNotEmpty ? topic.titleFa : topic.titleDe);
  }
}

String localizedGrammarTopicDescription(GrammarTopic topic, AppLanguage lang) {
  switch (lang) {
    case AppLanguage.fa:
      return topic.descriptionFa.isNotEmpty
          ? topic.descriptionFa
          : (topic.descriptionEn.isNotEmpty ? topic.descriptionEn : topic.descriptionDe);
    case AppLanguage.ps:
      return topic.descriptionFa.isNotEmpty
          ? topic.descriptionFa
          : (topic.descriptionEn.isNotEmpty ? topic.descriptionEn : topic.descriptionDe);
    case AppLanguage.en:
      return topic.descriptionEn.isNotEmpty
          ? topic.descriptionEn
          : (topic.descriptionFa.isNotEmpty ? topic.descriptionFa : topic.descriptionDe);
  }
}
