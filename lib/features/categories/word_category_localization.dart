import 'package:word_map_app/l10n/app_localizations.dart';

const Set<String> grammarCategoryTags = {
  'verb',
  'noun',
  'adjective',
  'adverb',
  'pronoun',
  'article',
  'preposition',
  'conjunction',
  'modal_verb',
  'separable_verb',
  'reflexive_verb',
  'irregular_verb',
  'question_word',
  'negation',
  'numbers',
  'time_expression',
  'place_expression',
};

const Set<String> adminCategoryTags = {
  'proper_noun',
  'loanword_international',
  'abbreviation',
  'uncategorized',
  'a1_core',
};

String localizeWordCategoryTag(AppLocalizations loc, String tag) {
  switch (tag) {
    case 'a1_core':
      return loc.tagA1Core;
    case 'daily_life':
      return loc.tagDailyLife;
    case 'conversation_phrases':
      return loc.tagConversationPhrases;
    case 'greetings_politeness':
      return loc.tagGreetingsPoliteness;
    case 'questions_answers':
      return loc.tagQuestionsAnswers;
    case 'time_date':
      return loc.tagTimeDate;
    case 'numbers_math':
      return loc.tagNumbersMath;
    case 'colors_shapes':
      return loc.tagColorsShapes;
    case 'days_months_seasons':
      return loc.tagDaysMonthsSeasons;
    case 'weather':
      return loc.tagWeather;
    case 'directions_navigation':
      return loc.tagDirectionsNavigation;
    case 'places_buildings':
      return loc.tagPlacesBuildings;
    case 'city_transport':
      return loc.tagCityTransport;
    case 'travel_holidays':
      return loc.tagTravelHolidays;
    case 'home_household':
      return loc.tagHomeHousehold;
    case 'furniture_rooms':
      return loc.tagFurnitureRooms;
    case 'kitchen_cooking':
      return loc.tagKitchenCooking;
    case 'food_drink':
      return loc.tagFoodDrink;
    case 'shopping_money':
      return loc.tagShoppingMoney;
    case 'clothing_fashion':
      return loc.tagClothingFashion;
    case 'health_body':
      return loc.tagHealthBody;
    case 'feelings_emotions':
      return loc.tagFeelingsEmotions;
    case 'people_family':
      return loc.tagPeopleFamily;
    case 'relationships':
      return loc.tagRelationships;
    case 'school_learning':
      return loc.tagSchoolLearning;
    case 'work_office':
      return loc.tagWorkOffice;
    case 'jobs_professions':
      return loc.tagJobsProfessions;
    case 'technology_internet':
      return loc.tagTechnologyInternet;
    case 'media_social':
      return loc.tagMediaSocial;
    case 'hobbies_sports':
      return loc.tagHobbiesSports;
    case 'nature_animals':
      return loc.tagNatureAnimals;
    case 'plants_environment':
      return loc.tagPlantsEnvironment;
    case 'culture_events':
      return loc.tagCultureEvents;
    case 'services_authorities':
      return loc.tagServicesAuthorities;
    case 'religion_culture':
      return loc.tagReligionCulture;
    case 'safety_emergency':
      return loc.tagSafetyEmergency;
    case 'law_rules':
      return loc.tagLawRules;
    case 'verb':
      return loc.tagVerb;
    case 'noun':
      return loc.tagNoun;
    case 'adjective':
      return loc.tagAdjective;
    case 'adverb':
      return loc.tagAdverb;
    case 'pronoun':
      return loc.tagPronoun;
    case 'article':
      return loc.tagArticle;
    case 'preposition':
      return loc.tagPreposition;
    case 'conjunction':
      return loc.tagConjunction;
    case 'modal_verb':
      return loc.tagModalVerb;
    case 'separable_verb':
      return loc.tagSeparableVerb;
    case 'reflexive_verb':
      return loc.tagReflexiveVerb;
    case 'irregular_verb':
      return loc.tagIrregularVerb;
    case 'question_word':
      return loc.tagQuestionWord;
    case 'negation':
      return loc.tagNegation;
    case 'numbers':
      return loc.tagNumbers;
    case 'time_expression':
      return loc.tagTimeExpression;
    case 'place_expression':
      return loc.tagPlaceExpression;
    case 'proper_noun':
      return loc.tagProperNoun;
    case 'loanword_international':
      return loc.tagLoanwordInternational;
    case 'abbreviation':
      return loc.tagAbbreviation;
    case 'uncategorized':
      return loc.tagUncategorized;
    default:
      return tag;
  }
}

String? formatCategoryLabel(AppLocalizations loc, List<String> tags, {int max = 2}) {
  if (tags.isEmpty) return null;
  final localized = tags.map((t) => localizeWordCategoryTag(loc, t)).toList();
  return localized.take(max).join(', ');
}

