# Adding words

1. Give the prompt below to another AI, followed by your words: a list, a table, a photo of
   a book page, or just a topic. Levels or translations you write next to a word are kept.
2. Save its answer as a `.json` file (a pasted ```json block is fine too). Long lists come
   in parts of 60 words; write "next" to get the next part.
3. Send the file to Claude, or check it and add it yourself:

   ```
   python3 tools/add_words.py new_words.json --check
   python3 tools/add_words.py new_words.json
   ```

`add_words.py` checks tags, articles and translations. It never adds a word twice: a word
that is already in the app ("weder ... noch" = "weder … noch") keeps its id and level,
gets the new tags, the new translations when they cover all its old meanings, and
anything it was missing; it prints what it merged. `a1_core` is only kept for A1 words.
It gives each new word an id and adds it to its level file (`B1.2` → `files/words/b1_2.json`). Verbs get their tables of tenses from
`tools/verbs/top-german-verbs.csv`. A verb missing there is built from the listed verb it
is made from ("hochladen" from "laden", "versenden" from "senden"); regular "-ieren"
verbs are built by rule. Only when none of that works are the `"verb"` key forms below
used. Entries such as "warten auf" or "sich freuen über" get the tables of the verb.

## Prompt

````text
You are building German vocabulary for a language-learning app.
After this prompt I give you German words: a list, a table, a photo of a book page, or a
topic. Turn them into entries in the format below.

- Take every German word or phrase I give, each exactly once. Do not add others, unless
  I only give a topic; then choose fitting words yourself.
- Keep anything I write next to a word: a level, a topic or a translation. A heading such
  as "B1.2 – Arbeit" applies to all words under it. Fill in everything I did not give.
- Return ONLY a JSON array (no explanation, no comments). One object per word.
- At most 60 words per answer. If there are more, stop after 60 and wait until I write
  "next"; then return the next 60 as a new JSON array.

A noun:

{
  "level": "A2.1",
  "category": ["food_drink", "noun"],
  "article": "die",
  "plural": "Bananen",
  "words": {
    "de": "Banane",
    "en": "banana",
    "fa": "موز",
    "ps": "کېله",
    "fr": "banane",
    "tr": "muz"
  },
  "examples": { "de": "Ich esse jeden Morgen eine Banane." }
}

A verb (it has a "verb" object; nothing else does):

{
  "level": "A2.1",
  "category": ["shopping_money", "verb", "separable_verb"],
  "words": {
    "de": "einkaufen",
    "en": "to shop",
    "fa": "خرید کردن",
    "ps": "سودا کول",
    "fr": "faire les courses",
    "tr": "alışveriş yapmak"
  },
  "examples": { "de": "Am Samstag kaufe ich im Supermarkt ein." },
  "verb": {
    "praesens_ich": "kaufe ein",
    "praesens_du": "kaufst ein",
    "praesens_er": "kauft ein",
    "praeteritum": "kaufte ein",
    "partizip2": "eingekauft",
    "konjunktiv2": "kaufte ein",
    "imperativ_du": "kauf ein",
    "imperativ_ihr": "kauft ein",
    "hilfsverb": "haben"
  }
}

Rules:
- "level": one of A1.1, A1.2, A2.1, A2.2, B1.1, B1.2, B2.1, B2.2, C1.1, C1.2.
  If I give none, use the word's level in the Goethe/telc word lists.
- "words.de": the dictionary form. Nouns WITHOUT article and capitalized ("Banane"),
  verbs in the infinitive ("einkaufen"), reflexive verbs with "sich" ("sich freuen"),
  fixed phrases as written ("rund um die Uhr").
- "article": only for nouns, exactly "der", "die" or "das". Leave it out for other words.
- "plural": only for nouns that have a plural, without article ("Bananen").
- "verb": ONLY for verbs. Leave it out for every other word, including phrases.
  - All forms without pronoun: "kaufe ein", not "ich kaufe ein".
  - "praeteritum" and "konjunktiv2" are the ich forms ("kaufte ein", "käme").
  - Separable verbs: the particle goes last, after a space ("kaufe ein", "kauf ein").
    Only "partizip2" is one word ("eingekauft").
  - Reflexive verbs: leave out "sich" and the reflexive pronoun
    ("sich anmelden" → "melde an", "angemeldet").
  - "imperativ_du" / "imperativ_ihr": without "!". Modal verbs have none: use "—".
  - "hilfsverb": exactly "haben" or "sein", the one used in the Perfekt.
- "words": translations in English (en), Farsi (fa), Pashto (ps), French (fr) and
  Turkish (tr). Short, like a dictionary. Two meanings: "tired / exhausted".
  English verbs start with "to ". No notes, no grammar remarks, no German inside
  the translations; translate every word, even international ones ("Radio" → "رادیو").
  Farsi: standard Iranian Persian ("موز", "بیمارستان"). Pashto: in Pashto script
  ("کېله", "روغتون").
- "category": 1 to 3 tags, ONLY from this list. Use one topic tag and one word-type
  tag when possible; use "uncategorized" only if nothing fits:
  a1_core, daily_life, conversation_phrases, greetings_politeness, questions_answers,
  time_date, numbers_math, colors_shapes, days_months_seasons, weather,
  directions_navigation, places_buildings, city_transport, travel_holidays,
  home_household, furniture_rooms, kitchen_cooking, food_drink, shopping_money,
  clothing_fashion, health_body, feelings_emotions, people_family, relationships,
  school_learning, work_office, jobs_professions, technology_internet, media_social,
  hobbies_sports, nature_animals, plants_environment, culture_events,
  services_authorities, religion_culture, safety_emergency, law_rules,
  verb, noun, adjective, adverb, pronoun, article, preposition, conjunction,
  modal_verb, separable_verb, reflexive_verb, irregular_verb, question_word,
  negation, numbers, time_expression, place_expression, proper_noun,
  loanword_international, abbreviation, uncategorized
- Every verb gets the "verb" tag, plus "separable_verb", "reflexive_verb",
  "modal_verb" or "irregular_verb" when that applies.
- "examples": every word gets one short, natural, correct German sentence at the
  word's level that uses the word.
- Do not add ids, audio or images. Do not repeat a word.
- Output valid JSON: double quotes, no trailing commas.

My words:
````

## How verb tables are made

From the key forms, `tools/verb_forms.py` builds these tables, one row per person:

| Tense | Built from |
|---|---|
| Präsens | ich, du, er forms; wir/sie = infinitive; ihr from the stem |
| Präteritum | ich form + endings |
| Perfekt, Plusquamperfekt | haben/sein (hatte/war) + Partizip II |
| Futur I | werden + infinitive |
| Konjunktiv II | the verb's own forms for sein, haben, werden, the modal verbs and a few common verbs (käme, ginge, wüsste …); "würde" + infinitive for all others |
| Imperativ | du, ihr, Sie (none for modal verbs) |

The tables are saved as `"forms"` in the word's entry. The app shows them as tense
buttons on the word card, and a text's words are found in any of these forms
("kam", "ist gekommen" → kommen).
