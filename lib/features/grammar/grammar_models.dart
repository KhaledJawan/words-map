class GrammarExample {
  const GrammarExample({required this.de, required this.fa});

  final String de;
  final String fa;
}

class GrammarTopic {
  const GrammarTopic({
    required this.id,
    required this.titleEn,
    required this.titleFa,
    required this.titleDe,
    required this.level,
    required this.descriptionEn,
    required this.descriptionFa,
    required this.descriptionDe,
    required this.examples,
    required this.assetPath,
  });

  final String id;
  final String titleEn;
  final String titleFa;
  final String titleDe;
  final String level;
  final String descriptionEn;
  final String descriptionFa;
  final String descriptionDe;
  final List<GrammarExample> examples;
  final String assetPath;
}

class GrammarCategory {
  const GrammarCategory({
    required this.id,
    required this.title,
    required this.folder,
    required this.topics,
  });

  final String id;
  final String title;
  final String folder;
  final List<GrammarTopic> topics;
}
