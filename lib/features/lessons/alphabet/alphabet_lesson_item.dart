class AlphabetLessonItem {
  final String id;
  final String subjectEn;
  final String subjectFa;
  final String subjectDe;
  final String descriptionEn;
  final String descriptionFa;
  final List<String> examplesEn;
  final List<String> examplesFa;
  final String audioDe;
  final List<String> images;
  final String category;

  const AlphabetLessonItem({
    required this.id,
    required this.subjectEn,
    required this.subjectFa,
    required this.subjectDe,
    required this.descriptionEn,
    required this.descriptionFa,
    required this.examplesEn,
    required this.examplesFa,
    required this.audioDe,
    required this.images,
    required this.category,
  });

  factory AlphabetLessonItem.fromJson(Map<String, dynamic> json) {
    List<String> asStringList(dynamic value) {
      if (value is List) {
        return value.whereType<String>().toList();
      }
      return const [];
    }

    return AlphabetLessonItem(
      id: json['id'] as String? ?? '',
      subjectEn: json['subject_en'] as String? ?? '',
      subjectFa: json['subject_fa'] as String? ?? '',
      subjectDe: json['subject_de'] as String? ?? '',
      descriptionEn: json['description_en'] as String? ?? '',
      descriptionFa: json['description_fa'] as String? ?? '',
      examplesEn: asStringList(json['examples_en']),
      examplesFa: asStringList(json['examples_fa']),
      audioDe: json['audio_de'] as String? ?? '',
      images: asStringList(json['images']),
      category: json['category'] as String? ?? '',
    );
  }
}
