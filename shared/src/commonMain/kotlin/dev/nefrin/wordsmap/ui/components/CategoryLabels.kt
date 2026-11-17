package dev.nefrin.wordsmap.ui.components

import androidx.compose.runtime.Composable
import androidx.compose.runtime.ReadOnlyComposable
import dev.nefrin.wordsmap.resources.Strings
import dev.nefrin.wordsmap.resources.stringResource

private val tagLabels = mapOf(
    "a1_core" to Strings.tag_a1_core,
    "daily_life" to Strings.tag_daily_life,
    "conversation_phrases" to Strings.tag_conversation_phrases,
    "greetings_politeness" to Strings.tag_greetings_politeness,
    "questions_answers" to Strings.tag_questions_answers,
    "time_date" to Strings.tag_time_date,
    "numbers_math" to Strings.tag_numbers_math,
    "colors_shapes" to Strings.tag_colors_shapes,
    "days_months_seasons" to Strings.tag_days_months_seasons,
    "weather" to Strings.tag_weather,
    "directions_navigation" to Strings.tag_directions_navigation,
    "places_buildings" to Strings.tag_places_buildings,
    "city_transport" to Strings.tag_city_transport,
    "travel_holidays" to Strings.tag_travel_holidays,
    "home_household" to Strings.tag_home_household,
    "furniture_rooms" to Strings.tag_furniture_rooms,
    "kitchen_cooking" to Strings.tag_kitchen_cooking,
    "food_drink" to Strings.tag_food_drink,
    "shopping_money" to Strings.tag_shopping_money,
    "clothing_fashion" to Strings.tag_clothing_fashion,
    "health_body" to Strings.tag_health_body,
    "feelings_emotions" to Strings.tag_feelings_emotions,
    "people_family" to Strings.tag_people_family,
    "relationships" to Strings.tag_relationships,
    "school_learning" to Strings.tag_school_learning,
    "work_office" to Strings.tag_work_office,
    "jobs_professions" to Strings.tag_jobs_professions,
    "technology_internet" to Strings.tag_technology_internet,
    "media_social" to Strings.tag_media_social,
    "hobbies_sports" to Strings.tag_hobbies_sports,
    "nature_animals" to Strings.tag_nature_animals,
    "plants_environment" to Strings.tag_plants_environment,
    "culture_events" to Strings.tag_culture_events,
    "services_authorities" to Strings.tag_services_authorities,
    "religion_culture" to Strings.tag_religion_culture,
    "safety_emergency" to Strings.tag_safety_emergency,
    "law_rules" to Strings.tag_law_rules,
    "verb" to Strings.tag_verb,
    "noun" to Strings.tag_noun,
    "adjective" to Strings.tag_adjective,
    "adverb" to Strings.tag_adverb,
    "pronoun" to Strings.tag_pronoun,
    "article" to Strings.tag_article,
    "preposition" to Strings.tag_preposition,
    "conjunction" to Strings.tag_conjunction,
    "modal_verb" to Strings.tag_modal_verb,
    "separable_verb" to Strings.tag_separable_verb,
    "reflexive_verb" to Strings.tag_reflexive_verb,
    "irregular_verb" to Strings.tag_irregular_verb,
    "question_word" to Strings.tag_question_word,
    "negation" to Strings.tag_negation,
    "numbers" to Strings.tag_numbers,
    "time_expression" to Strings.tag_time_expression,
    "place_expression" to Strings.tag_place_expression,
    "proper_noun" to Strings.tag_proper_noun,
    "loanword_international" to Strings.tag_loanword_international,
    "abbreviation" to Strings.tag_abbreviation,
    "uncategorized" to Strings.tag_uncategorized,
)

/** Name of a word category tag in the current language; unknown tags are shown as they are. */
@Composable
@ReadOnlyComposable
fun categoryLabel(tag: String): String = tagLabels[tag]?.let { stringResource(it) } ?: tag

/** The first [max] category names of a word, or null when it has none. */
@Composable
@ReadOnlyComposable
fun categoryLabels(tags: List<String>, max: Int = 2): String? =
    if (tags.isEmpty()) null else tags.take(max).map { categoryLabel(it) }.joinToString(", ")
