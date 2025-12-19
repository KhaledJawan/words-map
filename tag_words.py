#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import json
import os
import re
from collections import Counter, defaultdict
from typing import Any, Dict, List, Optional, Tuple


ALLOWED_TAGS = {
    # Core / high utility
    "a1_core",
    "daily_life",
    "conversation_phrases",
    "greetings_politeness",
    "questions_answers",
    "time_date",
    "numbers_math",
    "colors_shapes",
    "days_months_seasons",
    "weather",
    "directions_navigation",
    "places_buildings",
    "city_transport",
    "travel_holidays",
    "home_household",
    "furniture_rooms",
    "kitchen_cooking",
    "food_drink",
    "shopping_money",
    "clothing_fashion",
    "health_body",
    "feelings_emotions",
    "people_family",
    "relationships",
    "school_learning",
    "work_office",
    "jobs_professions",
    "technology_internet",
    "media_social",
    "hobbies_sports",
    "nature_animals",
    "plants_environment",
    "culture_events",
    "services_authorities",
    "religion_culture",
    "safety_emergency",
    "law_rules",
    # Grammar / function tags
    "verb",
    "noun",
    "adjective",
    "adverb",
    "pronoun",
    "article",
    "preposition",
    "conjunction",
    "modal_verb",
    "separable_verb",
    "reflexive_verb",
    "irregular_verb",
    "question_word",
    "negation",
    "numbers",
    "time_expression",
    "place_expression",
    # Administrative / quality tags
    "proper_noun",
    "loanword_international",
    "abbreviation",
    "uncategorized",
}


def load_json(path: str):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def save_json(path: str, data: Any):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")


def _norm(s: str) -> str:
    return re.sub(r"\s+", " ", (s or "").strip())


def _lower(s: str) -> str:
    return _norm(s).lower()


def _first_word(s: str) -> str:
    return _lower(s).split(" ", 1)[0] if _lower(s) else ""


def _match_text(s: str) -> str:
    s = _lower(s)
    s = re.sub(r"[^0-9a-zäöüß]+", " ", s)
    return re.sub(r"\s+", " ", s).strip()


def _has_any(s: str, keywords: List[str]) -> bool:
    hay = f" {_match_text(s)} "
    for kw in keywords:
        k = _match_text(kw)
        if not k:
            continue
        if f" {k} " in hay:
            return True
    return False


def _contains_any(s: str, needles: List[str]) -> bool:
    hay = _match_text(s)
    for n in needles:
        needle = _match_text(n)
        if needle and needle in hay:
            return True
    return False


ARTICLES = {
    "der",
    "die",
    "das",
    "ein",
    "eine",
    "einen",
    "einem",
    "einer",
    "eines",
    "den",
    "dem",
    "des",
}

PRONOUNS = {
    "ich",
    "du",
    "er",
    "sie",
    "es",
    "wir",
    "ihr",
    "mich",
    "dich",
    "ihn",
    "uns",
    "euch",
    "ihnen",
    "mir",
    "dir",
    "ihm",
    "mein",
    "meine",
    "meiner",
    "meinen",
    "dein",
    "deine",
    "sein",
    "seine",
    "ihr",
    "ihre",
    "unser",
    "unsere",
    "euer",
    "eure",
    "dies",
    "diese",
    "dieser",
    "dieses",
    "das",
    "der",
    "die",
}

PREPOSITIONS = {
    "in",
    "an",
    "auf",
    "unter",
    "über",
    "vor",
    "hinter",
    "neben",
    "zwischen",
    "mit",
    "ohne",
    "für",
    "gegen",
    "bei",
    "nach",
    "von",
    "zu",
    "aus",
    "um",
    "seit",
    "durch",
    "bis",
    "während",
}

CONJUNCTIONS = {
    "und",
    "oder",
    "aber",
    "denn",
    "weil",
    "dass",
    "wenn",
    "als",
    "ob",
    "obwohl",
    "sondern",
}

QUESTION_WORDS = {
    "wer",
    "wen",
    "wem",
    "was",
    "wann",
    "wo",
    "wohin",
    "woher",
    "wie",
    "warum",
    "wieso",
    "weshalb",
    "welcher",
    "welche",
    "welches",
    "wieviel",
    "wieviele",
}

NEGATIONS = {"nicht", "nie", "nichts", "kein", "keine", "keinen", "keinem", "keiner", "keines"}

COMMON_ADVERBS = {
    "ja",
    "nein",
    "auch",
    "sehr",
    "nur",
    "schon",
    "noch",
    "immer",
    "oft",
    "manchmal",
    "selten",
    "hier",
    "dort",
    "da",
    "jetzt",
    "heute",
    "gestern",
    "morgen",
    "abends",
    "nachts",
    "danach",
    "dann",
    "gleich",
    "bald",
    "später",
    "vielleicht",
    "leider",
    "gern",
    "gerne",
    "bitte",
}

TIME_EXPRESSIONS = {
    "heute",
    "gestern",
    "morgen",
    "jetzt",
    "bald",
    "später",
    "abends",
    "nachts",
    "danach",
    "dann",
    "immer",
    "nie",
    "oft",
    "manchmal",
    "selten",
}

PLACE_EXPRESSIONS = {"hier", "dort", "da", "links", "rechts", "oben", "unten", "vorn", "vorne", "hinten", "draußen", "drinnen", "geradeaus"}

MODAL_VERBS = {"können", "müssen", "dürfen", "sollen", "wollen", "mögen", "möchten"}
IRREGULAR_VERBS = {"sein", "haben", "werden", "gehen", "kommen", "nehmen", "geben", "sehen", "essen", "trinken"}

GERMAN_NUMBER_WORDS = {
    "null",
    "eins",
    "zwei",
    "drei",
    "vier",
    "fünf",
    "sechs",
    "sieben",
    "acht",
    "neun",
    "zehn",
    "elf",
    "zwölf",
    "dreizehn",
    "vierzehn",
    "fünfzehn",
    "sechzehn",
    "siebzehn",
    "achtzehn",
    "neunzehn",
    "zwanzig",
    "dreißig",
    "vierzig",
    "fünfzig",
    "sechzig",
    "siebzig",
    "achtzig",
    "neunzig",
    "hundert",
    "tausend",
    "million",
}

COLORS_EN = {
    "red",
    "blue",
    "green",
    "yellow",
    "orange",
    "black",
    "white",
    "grey",
    "gray",
    "brown",
    "pink",
    "purple",
}
SHAPES_EN = {"circle", "square", "triangle", "rectangle", "oval", "star", "heart"}

DAYS_EN = {
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday",
}
MONTHS_EN = {
    "january",
    "february",
    "march",
    "april",
    "may",
    "june",
    "july",
    "august",
    "september",
    "october",
    "november",
    "december",
}
SEASONS_EN = {"spring", "summer", "autumn", "fall", "winter"}

PROPER_NOUN_DE = {
    "deutschland",
    "berlin",
    "hamburg",
    "münchen",
    "köln",
    "köln",
    "frankfurt",
    "wien",
    "zürich",
    "schweiz",
    "österreich",
    "europa",
    "afrika",
    "amerika",
    "asien",
    "deutsch",
    "england",
    "frankreich",
    "italien",
    "spanien",
}


def infer_pos_tags(word: str, translation_en: str) -> List[str]:
    w = _norm(word)
    w_l = _lower(word)
    en_l = _lower(translation_en)
    first = _first_word(word)
    tags: List[str] = []

    if re.fullmatch(r"[A-ZÄÖÜ]{2,6}\.?", w.strip()):
        tags.append("abbreviation")

    if first in ARTICLES:
        tags.append("article")
    if first in PRONOUNS or w_l in PRONOUNS:
        tags.append("pronoun")
    if first in PREPOSITIONS or w_l in PREPOSITIONS:
        tags.append("preposition")
    if first in CONJUNCTIONS or w_l in CONJUNCTIONS:
        tags.append("conjunction")
    if first in QUESTION_WORDS or w_l in QUESTION_WORDS:
        tags.append("question_word")
    if first in NEGATIONS or w_l in NEGATIONS:
        tags.append("negation")

    if w_l in GERMAN_NUMBER_WORDS or re.fullmatch(r"\d+([.,]\d+)?", w_l):
        tags.append("numbers")

    if w_l in TIME_EXPRESSIONS:
        tags.append("time_expression")
    if w_l in PLACE_EXPRESSIONS:
        tags.append("place_expression")

    if w_l.startswith("sich "):
        tags.append("reflexive_verb")
        tags.append("verb")
        return _dedupe(tags)

    if en_l.startswith("to "):
        tags.append("verb")
    if w_l in MODAL_VERBS:
        tags.append("modal_verb")
        if "verb" not in tags:
            tags.append("verb")
    if w_l in IRREGULAR_VERBS and "verb" in tags:
        tags.append("irregular_verb")

    # Noun inference (word lists usually capitalize nouns)
    if w and w[0].isupper():
        if "pronoun" not in tags and "article" not in tags and "abbreviation" not in tags:
            tags.append("noun")

    # Adverbs (curated list)
    if w_l in COMMON_ADVERBS:
        tags.append("adverb")

    # Adjectives (high-precision heuristics)
    if (
        " " not in w_l
        and w_l
        and w_l.islower()
        and "verb" not in tags
        and "noun" not in tags
        and not en_l.startswith("to ")
    ):
        if w_l in {
            "gut",
            "schlecht",
            "groß",
            "klein",
            "schön",
            "teuer",
            "billig",
            "neu",
            "alt",
            "jung",
            "müde",
            "hungrig",
            "durstig",
            "krank",
            "gesund",
            "glücklich",
            "traurig",
            "wütend",
            "ängstlich",
            "warm",
            "kalt",
            "heiß",
            "hell",
            "dunkel",
            "laut",
            "leise",
            "modern",
            "einfach",
            "interessant",
            "schnell",
            "normal",
            "aggressiv",
            "lecker",
            "süß",
            "ungesund",
            "toll",
            "super",
            "gelb",
            "blau",
            "grün",
            "rot",
            "schwarz",
            "weiß",
            "grau",
            "braun",
        }:
            tags.append("adjective")
        elif re.search(r"(ig|lich|isch|bar|los|voll|sam|haft|end)$", w_l):
            tags.append("adjective")

    return _dedupe(tags)


def infer_topical_tag(word: str, translation_en: str, translation_fa: str) -> Optional[str]:
    w_l = _lower(word)
    en_l = _lower(translation_en)
    fa_l = _lower(translation_fa)
    w_m = _match_text(word)
    en_m = _match_text(translation_en)
    fa_m = _match_text(translation_fa)

    # Proper nouns (conservative)
    if (
        w_l in PROPER_NOUN_DE
        or en_l in PROPER_NOUN_DE
        or re.fullmatch(r"[A-ZÄÖÜ][a-zäöüß]+", _norm(word)) and en_l in {"germany", "austria", "switzerland"}
    ):
        return "proper_noun"

    # Greetings / politeness / conversational templates
    if "?" in word or (en_l.startswith(("how ", "where ", "when ", "why ", "what ", "who "))) or _first_word(word) in QUESTION_WORDS:
        return "questions_answers"

    if _contains_any(word, ["hallo", "hi", "tschüss", "auf wiedersehen", "guten morgen", "guten tag", "guten abend", "gute nacht", "willkommen", "entschuldigung", "danke", "bitte"]):
        return "greetings_politeness"

    if _contains_any(word, ["mein name ist", "wie geht", "ich heiße", "freut mich", "keine ahnung", "bis bald", "bis später"]):
        return "conversation_phrases"

    if _has_any(
        en_m,
        [
            "name",
            "first name",
            "last name",
            "address",
            "zip code",
            "postcode",
            "phone number",
            "telephone number",
            "age",
            "nationality",
        ],
    ) or _contains_any(w_m, ["vorname", "nachname", "adresse", "postleitzahl", "telefonnummer", "alter"]):
        return "conversation_phrases"

    if en_m in {"english", "french", "german", "persian", "pashto"} or _contains_any(w_m, ["englisch", "französisch", "deutsch", "persisch", "paschtu", "pashto"]):
        return "school_learning"

    # Time / date
    if _has_any(en_m, ["time", "date", "today", "tomorrow", "yesterday", "hour", "minute", "week", "month", "year"]) or w_l in TIME_EXPRESSIONS:
        return "time_date"

    if en_l in DAYS_EN or en_l in MONTHS_EN or en_l in SEASONS_EN:
        return "days_months_seasons"

    # Numbers / math
    if w_l in GERMAN_NUMBER_WORDS or re.fullmatch(r"\d+([.,]\d+)?", w_l) or _has_any(en_m, ["percent", "plus", "minus", "times", "divide"]):
        return "numbers_math"

    # Colors / shapes
    if en_m in COLORS_EN or en_m in SHAPES_EN or _has_any(en_m, list(COLORS_EN | SHAPES_EN)):
        return "colors_shapes"

    # Weather
    if _has_any(en_m, ["weather", "rain", "snow", "wind", "cloud", "sun", "sunny", "storm", "temperature"]) or _has_any(fa_m, ["هوا", "باران", "برف"]):
        return "weather"

    # Directions / navigation
    if _has_any(en_m, ["left", "right", "straight", "near", "far", "direction", "turn", "map"]) or w_l in PLACE_EXPRESSIONS:
        return "directions_navigation"

    # Places / buildings
    if _has_any(
        en_m,
        [
            "school",
            "university",
            "hospital",
            "pharmacy",
            "bank",
            "restaurant",
            "hotel",
            "airport",
            "station",
            "supermarket",
            "shop",
            "office",
            "post office",
            "city",
            "street",
        ],
    ):
        return "places_buildings"

    if _contains_any(w_m, ["schule", "berufskolleg", "fachschule", "uni", "universität"]):
        return "school_learning"

    if _contains_any(w_m, ["amt", "behörde", "antrag", "anmeldung", "zulassung", "ausweis", "pass", "visum", "versicherung"]):
        return "services_authorities"

    if _contains_any(w_m, ["arbeit", "arbeits", "beruf", "firma", "vertrag", "gehalt", "bewerbung", "vorstellungsgespräch", "interview"]):
        return "work_office"

    if _contains_any(w_m, ["kurs", "klasse", "prüfung", "hausaufgabe", "buch", "text", "dialog", "wort", "satz", "grammatik", "alphabet"]):
        return "school_learning"

    # City / transport
    if _has_any(en_m, ["bus", "train", "tram", "subway", "metro", "ticket", "taxi", "bicycle", "bike", "car", "traffic", "station", "platform", "stop"]):
        return "city_transport"

    # Travel / holidays
    if _has_any(en_m, ["travel", "trip", "vacation", "holiday", "passport", "luggage", "flight", "booking", "reservation", "tourist"]):
        return "travel_holidays"

    if _has_any(en_m, ["easter", "christmas", "new year"]) or _has_any(fa_m, ["عید", "کریسمس"]):
        return "culture_events"

    # Home / household / furniture / rooms
    if _has_any(en_m, ["apartment", "flat", "house", "home", "rent", "neighbor", "garden"]) or _has_any(fa_m, ["خانه", "آپارتمان"]):
        return "home_household"

    if _has_any(en_m, ["room", "kitchen", "bathroom", "bedroom", "living room", "chair", "table", "bed", "sofa", "wardrobe", "closet"]):
        return "furniture_rooms"

    # Kitchen / cooking / food & drink
    if _has_any(en_m, ["cook", "bake", "fry", "boil", "kitchen", "recipe"]):
        return "kitchen_cooking"

    if _has_any(
        en_m,
        [
            "food",
            "drink",
            "water",
            "coffee",
            "tea",
            "juice",
            "beer",
            "wine",
            "bread",
            "milk",
            "cheese",
            "meat",
            "fish",
            "fruit",
            "vegetable",
            "breakfast",
            "lunch",
            "dinner",
            "restaurant",
        ],
    ):
        return "food_drink"

    # Shopping / money
    if _has_any(en_m, ["buy", "sell", "pay", "price", "money", "euro", "cash", "card", "receipt", "bill", "change", "discount", "shopping", "purchase"]):
        return "shopping_money"

    # Clothing / fashion
    if _has_any(en_m, ["shirt", "t shirt", "dress", "pants", "trousers", "skirt", "jacket", "coat", "shoes", "sock", "hat", "clothes"]):
        return "clothing_fashion"

    # Health / body
    if _has_any(
        en_m,
        [
            "doctor",
            "hospital",
            "medicine",
            "pain",
            "ill",
            "sick",
            "healthy",
            "health",
            "body",
            "head",
            "hand",
            "foot",
            "leg",
            "arm",
            "eye",
            "ear",
            "nose",
            "mouth",
            "tooth",
            "stomach",
            "back",
        ],
    ):
        return "health_body"

    # Feelings / emotions
    if _has_any(en_m, ["happy", "sad", "angry", "afraid", "fear", "anxious", "tired", "bored", "excited", "love", "hate", "happiness", "luck", "satisfied", "great", "grateful", "good", "bad", "nice", "beautiful", "ok", "okay", "shock", "concern"]) or _has_any(fa_m, ["خوشحال", "غم", "عصبانی", "ترس"]):
        return "feelings_emotions"

    # People / family / relationships
    if _has_any(
        en_m,
        [
            "mother",
            "father",
            "sister",
            "brother",
            "parents",
            "family",
            "child",
            "son",
            "daughter",
            "grandmother",
            "grandfather",
            "siblings",
            "grandparents",
            "boy",
            "girl",
            "man",
            "woman",
            "person",
            "people",
            "mr",
            "mrs",
        ],
    ) or _has_any(fa_m, ["مادر", "پدر", "خواهر", "برادر", "خانواده"]):
        return "people_family"

    if _has_any(en_m, ["friend", "boyfriend", "girlfriend", "husband", "wife", "marriage", "relationship", "date", "marital status"]):
        return "relationships"

    # School / learning
    if _has_any(
        en_m,
        [
            "learn",
            "study",
            "lesson",
            "homework",
            "teacher",
            "student",
            "exam",
            "language",
            "alphabet",
            "grammar",
            "school",
            "course",
            "class",
            "book",
            "text",
            "dialogue",
            "letter",
            "to read",
            "to write",
            "to listen",
            "to understand",
            "to spell",
        ],
    ):
        return "school_learning"

    # Work / office / jobs
    if _has_any(en_m, ["work", "office", "meeting", "boss", "colleague", "company", "salary", "contract", "interview", "application", "deadline", "financial", "leadership", "management"]):
        return "work_office"

    if _has_any(en_m, ["job", "profession", "engineer", "doctor", "teacher", "driver", "cook", "police officer", "nurse"]):
        return "jobs_professions"

    # Technology / internet / media
    if _has_any(en_m, ["computer", "phone", "smartphone", "internet", "website", "email", "password", "app", "wifi", "install", "copy", "download", "upload", "update", "file", "print", "printer", "digitalization", "digitalisation", "research", "invention"]):
        return "technology_internet"

    if _has_any(en_m, ["news", "newspaper", "radio", "tv", "television", "social media", "post", "message", "chat"]):
        return "media_social"

    # Hobbies / sports
    if _has_any(en_m, ["sport", "football", "soccer", "tennis", "swim", "run", "gym", "music", "dance", "hobby", "jogging"]):
        return "hobbies_sports"

    # Nature / animals / plants / environment
    if _has_any(en_m, ["dog", "cat", "animal", "bird", "horse", "cow", "fish"]) or _has_any(fa_m, ["سگ", "گربه", "حیوان"]):
        return "nature_animals"

    if _has_any(en_m, ["tree", "flower", "plant", "forest", "environment", "recycle", "climate", "nature"]) or _has_any(fa_m, ["درخت", "گل", "محیط"]):
        return "plants_environment"

    # Culture / events
    if _has_any(en_m, ["culture", "festival", "concert", "museum", "theatre", "cinema", "party", "event", "club", "disco"]):
        return "culture_events"

    # Services / authorities / safety / law
    if _has_any(en_m, ["police", "passport office", "embassy", "authority", "government", "office", "court", "confirmation", "validity", "citizenship", "naturalization", "document", "certificate", "permit", "registration"]):
        return "services_authorities"

    if _has_any(en_m, ["emergency", "help", "fire", "danger", "ambulance"]):
        return "safety_emergency"

    if _has_any(en_m, ["law", "rule", "fine", "ticket", "illegal"]):
        return "law_rules"

    if _has_any(en_m, ["church", "mosque", "prayer", "religion"]):
        return "religion_culture"

    return None


def _dedupe(tags: List[str]) -> List[str]:
    out: List[str] = []
    for t in tags:
        if t not in out:
            out.append(t)
    return out


def build_tags(item: Dict[str, Any]) -> List[str]:
    word = str(item.get("word", "") or "")
    en = str(item.get("translation_en", "") or "")
    fa = str(item.get("translation_fa", "") or "")
    level = str(item.get("level", "") or "")

    topical = infer_topical_tag(word, en, fa)
    pos_tags = infer_pos_tags(word, en)

    tags: List[str] = []

    w_l = _lower(word)

    # Decide topical/conversation defaults
    if topical == "proper_noun":
        tags.append("proper_noun")
        tags.append("noun")
        # Try to add a topic if we can infer it safely from translation
        inferred_topic = infer_topical_tag(" ", en, fa)
        if inferred_topic and inferred_topic != "proper_noun":
            tags.append(inferred_topic)
    elif topical:
        tags.append(topical)

    if topical is None:
        if "question_word" in pos_tags:
            tags.append("questions_answers")
            tags.append("conversation_phrases")
        elif any(t in pos_tags for t in ["article", "pronoun", "preposition", "conjunction", "negation", "adverb"]):
            tags.append("conversation_phrases")

        core_verbs = {
            "sein",
            "haben",
            "werden",
            "gehen",
            "kommen",
            "machen",
            "sagen",
            "sprechen",
            "lernen",
            "wohnen",
            "heißen",
            "kennen",
            "fragen",
            "antworten",
        }
        if "verb" in pos_tags and str(item.get("level", "") or "").startswith("A1") and w_l.split(" ", 1)[0] in core_verbs:
            tags.append("daily_life")

    # Add conversation tags where appropriate
    w_norm = _norm(word)
    if topical in {"greetings_politeness", "questions_answers"}:
        tags.append("conversation_phrases")
    if "!" in w_norm and "conversation_phrases" not in tags and len(w_norm.split()) > 1:
        tags.append("conversation_phrases")

    # Add POS tags (only the most useful ones)
    for t in pos_tags:
        if t in {"abbreviation", "question_word", "negation", "modal_verb", "reflexive_verb", "irregular_verb", "verb", "noun", "adjective", "adverb", "pronoun", "article", "preposition", "conjunction", "numbers", "time_expression", "place_expression"}:
            tags.append(t)

    # loanword_international (conservative list)
    if _lower(word) in {"hotel", "restaurant", "internet", "computer", "radio", "taxi", "telefon"}:
        tags.append("loanword_international")

    # a1_core (conservative: only when highly likely)
    w_first = _first_word(word)
    w_l = _lower(word)
    core_words = (
        w_l in COMMON_ADVERBS
        or w_first in ARTICLES
        or w_first in PRONOUNS
        or w_first in PREPOSITIONS
        or w_first in CONJUNCTIONS
        or w_first in QUESTION_WORDS
        or w_first in NEGATIONS
        or w_l in MODAL_VERBS
        or w_l in IRREGULAR_VERBS
        or w_l in {"ja", "nein", "danke", "bitte"}
        or w_l in GERMAN_NUMBER_WORDS
    )
    if level.startswith("A1") and core_words:
        tags.append("a1_core")

    def looks_abstract(german: str, english: str) -> bool:
        g = _lower(german)
        e = _match_text(english)
        if re.search(r"(ung|heit|keit|schaft|tät|tion|ismus|ment)$", g):
            return True
        if _has_any(e, ["tion", "ness", "ment", "ship", "ism", "ability"]):
            return True
        return False

    # Broad but safe fallback for early levels: daily_life + POS (avoid for abstract nouns)
    if (
        topical is None
        and "daily_life" not in tags
        and (level.startswith("A1") or level.startswith("A2"))
        and any(t in pos_tags for t in ["noun", "verb", "adjective"])
        and not any(t in pos_tags for t in ["article", "pronoun", "preposition", "conjunction", "question_word", "negation"])
        and not looks_abstract(word, en)
        and not any(t in tags for t in ["greetings_politeness", "questions_answers", "conversation_phrases", "school_learning", "work_office"])
    ):
        tags.insert(0, "daily_life")

    tags = _dedupe([t for t in tags if t in ALLOWED_TAGS])

    # If no confident topical tag, do not guess.
    topical_like = [t for t in tags if t in ALLOWED_TAGS and t not in {
        "verb",
        "noun",
        "adjective",
        "adverb",
        "pronoun",
        "article",
        "preposition",
        "conjunction",
        "modal_verb",
        "separable_verb",
        "reflexive_verb",
        "irregular_verb",
        "question_word",
        "negation",
        "numbers",
        "time_expression",
        "place_expression",
        "proper_noun",
        "loanword_international",
        "abbreviation",
        "a1_core",
    }]

    if (
        "proper_noun" not in tags
        and not topical_like
        and "conversation_phrases" not in tags
        and "greetings_politeness" not in tags
        and "questions_answers" not in tags
    ):
        return ["uncategorized"]

    # Enforce tag-count limits (2–5); keep important tags.
    if tags == ["uncategorized"]:
        return tags

    priority: List[str] = []
    for t in [
        # topical
        "greetings_politeness",
        "questions_answers",
        "conversation_phrases",
        "time_date",
        "days_months_seasons",
        "numbers_math",
        "colors_shapes",
        "weather",
        "directions_navigation",
        "places_buildings",
        "city_transport",
        "travel_holidays",
        "home_household",
        "furniture_rooms",
        "kitchen_cooking",
        "food_drink",
        "shopping_money",
        "clothing_fashion",
        "health_body",
        "feelings_emotions",
        "people_family",
        "relationships",
        "school_learning",
        "work_office",
        "jobs_professions",
        "technology_internet",
        "media_social",
        "hobbies_sports",
        "nature_animals",
        "plants_environment",
        "culture_events",
        "services_authorities",
        "religion_culture",
        "safety_emergency",
        "law_rules",
        "daily_life",
        # admin/core
        "proper_noun",
        "loanword_international",
        "abbreviation",
        "a1_core",
        # grammar
        "verb",
        "modal_verb",
        "reflexive_verb",
        "irregular_verb",
        "noun",
        "adjective",
        "adverb",
        "question_word",
        "negation",
        "numbers",
        "time_expression",
        "place_expression",
        "pronoun",
        "article",
        "preposition",
        "conjunction",
    ]:
        if t in tags and t not in priority:
            priority.append(t)

    priority = priority[:5]
    if len(priority) == 1:
        return ["uncategorized"]
    return priority


def upsert_category_preserving_order(item: Dict[str, Any], category_tags: List[str]) -> Dict[str, Any]:
    """
    Replace legacy string `category` and `tags` with a single `category` field:
      "category": ["...", "..."]
    """
    out: Dict[str, Any] = {}
    inserted = False

    for k, v in item.items():
        if k == "tags":
            if not inserted:
                out["category"] = category_tags
                inserted = True
            continue
        if k == "category":
            # Drop old category (e.g. "A1") per migration request.
            if not inserted:
                out["category"] = category_tags
                inserted = True
            continue
        out[k] = v

    if not inserted:
        out["category"] = category_tags

    return out


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", default="assets/words", help="Directory containing word json files")
    ap.add_argument("--write", action="store_true", help="Write changes in-place")
    args = ap.parse_args()

    word_files = sorted(
        os.path.join(args.dir, p)
        for p in os.listdir(args.dir)
        if p.endswith(".json") and os.path.isfile(os.path.join(args.dir, p))
    )

    tag_counts: Counter[str] = Counter()
    uncategorized_by_file: Dict[str, List[Tuple[str, str]]] = defaultdict(list)
    total_words = 0

    updated_files: Dict[str, Any] = {}
    for path in word_files:
        data = load_json(path)
        if not isinstance(data, list):
            continue
        out_list: List[Any] = []
        for item in data:
            if not isinstance(item, dict):
                out_list.append(item)
                continue
            total_words += 1
            tags = build_tags(item)
            for t in tags:
                tag_counts[t] += 1
            if tags == ["uncategorized"]:
                uncategorized_by_file[os.path.basename(path)].append(
                    (str(item.get("id", "")), str(item.get("word", "")))
                )
            out_list.append(upsert_category_preserving_order(item, tags))
        updated_files[path] = out_list

    if args.write:
        for path, data in updated_files.items():
            save_json(path, data)

    # Report
    print(f"files_processed={len(word_files)}")
    print(f"total_words_tagged={total_words}")

    top20 = tag_counts.most_common(20)
    print("top_20_tags=" + ", ".join([f"{k}:{v}" for k, v in top20]))

    total_uncat = sum(len(v) for v in uncategorized_by_file.values())
    print(f"uncategorized_total={total_uncat}")
    if total_uncat:
        for fname in sorted(uncategorized_by_file.keys()):
            items = uncategorized_by_file[fname]
            print(f"uncategorized_file={fname} count={len(items)}")
            # Keep output bounded, but still actionable.
            for wid, w in items[:30]:
                print(f"  {wid} {w}")
            if len(items) > 30:
                print(f"  ... (+{len(items) - 30} more)")


if __name__ == "__main__":
    main()
