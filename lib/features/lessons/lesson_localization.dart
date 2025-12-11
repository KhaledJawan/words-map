import 'package:word_map_app/l10n/app_localizations.dart';
import 'package:word_map_app/features/lessons/lessons_repository.dart';

String localizedCategoryTitle(String categoryId, AppLocalizations loc) {
  switch (categoryId) {
    case 'beginner':
      return loc.lessonsCategoryBeginnerBasics;
    case 'grammar':
      return loc.lessonsCategoryGrammar;
    case 'reading_listening':
      return loc.lessonsCategoryReadingListening;
    case 'exam':
      return loc.lessonsCategoryExamPractice;
    default:
      return loc.lessonsTitle;
  }
}

String localizedGrammarLevelTitle(String level, AppLocalizations loc) {
  switch (level) {
    case 'A1':
      return loc.grammarLevelA1;
    case 'A2':
      return loc.grammarLevelA2;
    case 'B1':
      return loc.grammarLevelB1;
    case 'B2':
      return loc.grammarLevelB2;
    case 'C1':
      return loc.grammarLevelC1;
    default:
      return '$level Grammar';
  }
}

String localizedGrammarLevelLessonsCount(int count, AppLocalizations loc) =>
    loc.grammarLevelLessonsCount(count);

String localizedLessonsStatusComingSoon(AppLocalizations loc) => loc.lessonsStatusComingSoon;

String localizedLessonTitle(LessonItem lesson, AppLocalizations loc) {
  switch (lesson.id) {
    case 'alphabet':
      return loc.lessonBeginnerAlphabetTitle;
    case 'reading_rules':
      return loc.lessonBeginnerReadingRulesTitle;
    case 'parts_of_speech':
      return loc.lessonBeginnerPartsOfSpeechTitle;
    case 'hallo':
      return loc.lessonBeginnerHalloTitle;
    case 'all_about_german':
      return loc.lessonBeginnerAllAboutGermanTitle;
    default:
      return lesson.title;
  }
}

String localizedLessonSlideTitle(LessonSlide slide, AppLocalizations loc) {
  switch (slide.id) {
    case 'alphabet-slide-1':
      return loc.slideAlphabetOverviewTitle;
    case 'alphabet-slide-2':
      return loc.slideAlphabetVowelsTitle;
    case 'alphabet-slide-3':
      return loc.slideAlphabetUmlautTitle;
    case 'alphabet-slide-4':
      return loc.slideAlphabetEsszettTitle;
    case 'reading-slide-1':
      return loc.slideReadingBasicRuleTitle;
    case 'reading-slide-2':
      return loc.slideReadingSchChSpStTitle;
    case 'reading-slide-3':
      return loc.slideReadingCapitalLettersTitle;
    case 'reading-slide-4':
      return loc.slideReadingLongVsShortTitle;
    case 'parts-slide-1':
      return loc.slidePartsMainPartsTitle;
    case 'parts-slide-2':
      return loc.slidePartsNounsGenderTitle;
    case 'parts-slide-3':
      return loc.slidePartsVerbsInfinitiveTitle;
    case 'parts-slide-4':
      return loc.slidePartsAdjectivesTitle;
    case 'hallo-slide-1':
      return loc.slideHalloBasicGreetingsTitle;
    case 'hallo-slide-2':
      return loc.slideHalloIntroducingTitle;
    case 'hallo-slide-3':
      return loc.slideHalloHowAreYouTitle;
    case 'hallo-slide-4':
      return loc.slideHalloPoliteWordsTitle;
    case 'german-slide-1':
      return loc.slideGermanWhereSpokenTitle;
    case 'german-slide-2':
      return loc.slideGermanFormalInformalTitle;
    case 'german-slide-3':
      return loc.slideGermanWordOrderTitle;
    case 'german-slide-4':
      return loc.slideGermanLongWordsTitle;
    default:
      return slide.title ?? '';
  }
}
