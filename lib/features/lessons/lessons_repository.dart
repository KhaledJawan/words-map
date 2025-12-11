class LessonSlide {
  final String id;
  final String text;
  final String? title;

  const LessonSlide({
    required this.id,
    required this.text,
    this.title,
  });
}

class LessonItem {
  final String id;
  final String title;
  final String categoryId;
  final String? description;
  final List<LessonSlide> slides;

  const LessonItem({
    required this.id,
    required this.title,
    required this.categoryId,
    this.description,
    required this.slides,
  });
}

class LessonCategory {
  final String id;
  final String title;
  final String? description;
  final List<LessonItem> lessons;

  const LessonCategory({
    required this.id,
    required this.title,
    this.description,
    this.lessons = const [],
  });
}

class LessonsRepository {
  static final List<LessonCategory> categories = [
    LessonCategory(
      id: 'beginner',
      title: 'Beginner Basics',
      description: 'Start here: alphabet, reading, and daily exchanges.',
      lessons: [
        LessonItem(
          id: 'alphabet',
          title: 'Alphabet',
          categoryId: 'beginner',
          description: 'Get comfortable with the letters.',
          slides: [
            const LessonSlide(
              id: 'alphabet-slide-1',
              title: 'German Alphabet – Overview',
              text:
                  'The German alphabet has 26 basic letters like English (A–Z) plus 4 extra characters:\n\nÄ, Ö, Ü (called “Umlaut” vowels)\n\nß (called “Eszett” or “scharfes S”)\nExample:\n\nä like in “Mädchen”\n\nö like in “schön”\n\nü like in “Tschüss”\n\nß like in “Straße”',
            ),
            const LessonSlide(
              id: 'alphabet-slide-2',
              title: 'Vowels (A, E, I, O, U)',
              text:
                  'German vowels can be short or long.\n\nShort: “Mann”, “Sonne”, “Mitte”\n\nLong: “Name”, “Meer”, “Liebe”, “Boot”, “gut”\nOften, a doubled consonant after a vowel makes it short:\n\n“Mitte” (short i) vs “Miete” (long ie)',
            ),
            const LessonSlide(
              id: 'alphabet-slide-3',
              title: 'Umlaut vowels (Ä, Ö, Ü)',
              text:
                  'Umlaut vowels change the sound and sometimes the meaning.\n\na → ä : “Mann” vs “Männer”\n\no → ö : “schon” vs “schön”\n\nu → ü : “Mutter” vs “Mütter”\nIn typing, you can write them as:\n\nä → ae, ö → oe, ü → ue',
            ),
            const LessonSlide(
              id: 'alphabet-slide-4',
              title: 'ß – Eszett',
              text:
                  'ß is used only in German. It is pronounced like a sharp “s”.\n\nExample: “Straße”, “heißen”, “Fuß”\nIf you can’t type ß, you can use “ss”:\n\nStraße → Strasse, Fuß → Fuss',
            ),
          ],
        ),
        LessonItem(
          id: 'reading_rules',
          title: 'Reading rules',
          categoryId: 'beginner',
          description: 'Learn how letters combine.',
          slides: [
            const LessonSlide(
              id: 'reading-slide-1',
              title: 'Basic reading rule – “ie” vs “ei”',
              text:
                  'German has two important letter pairs:\n\n“ie” → long “i” (like “machine”)\n\n“ei” → like English “eye”\nExamples:\n\n“vier”, “lieben”, “Spiel” (ie → long i)\n\n“eins”, “mein”, “klein” (ei → eye sound)',
            ),
            const LessonSlide(
              id: 'reading-slide-2',
              title: '“sch”, “ch” and “sp / st”',
              text:
                  '“sch” → like English “sh”: “Schule”, “Fisch”\n\n“ch” has two sounds:\n\nafter e, i, ä, ö, ü → soft “ch”: “ich”, “leicht”\n\nafter a, o, u → strong “ch”: “Bach”, “noch”, “Buch”\nAt the beginning of a word:\n\n“sp” → “shp”: “Sport”, “spät”\n\n“st” → “sht”: “Straße”, “Stadt”',
            ),
            const LessonSlide(
              id: 'reading-slide-3',
              title: 'Capital letters (Nouns)',
              text:
                  'In German, all nouns start with a capital letter.\nExamples:\n\n“der Hund”, “die Frau”, “das Auto”, “die Stadt”\nThis helps you recognize nouns quickly in a sentence.',
            ),
            const LessonSlide(
              id: 'reading-slide-4',
              title: 'Long vs short vowels',
              text:
                  'Typical patterns:\n\nLong vowel: vowel + h → “fahren”, “sehen”\n\nLong vowel: double vowel → “Meer”, “Boot”\n\nShort vowel: vowel + double consonant → “Mitte”, “Mutter”\nYou don’t need to memorize every rule now, just start to notice these patterns when reading.',
            ),
          ],
        ),
        LessonItem(
          id: 'parts_of_speech',
          title: 'Parts of speech',
          categoryId: 'beginner',
          description: 'Simple mechanics of German grammar.',
          slides: [
            const LessonSlide(
              id: 'parts-slide-1',
              title: 'Main parts of speech',
              text:
                  'The most important word types in German:\n\nNomen (nouns): Dinge, Personen, Orte – “Auto”, “Frau”, “Berlin”\n\nVerben (verbs): Aktionen – “gehen”, “lernen”, “schlafen”\n\nAdjektive (adjectives): Eigenschaften – “groß”, “klein”, “schnell”\n\nArtikel (articles): “der”, “die”, “das”, “ein”, “eine”',
            ),
            const LessonSlide(
              id: 'parts-slide-2',
              title: 'Nouns and gender',
              text:
                  'Every German noun has a gender:\n\nder (maskulin)\n\ndie (feminin)\n\ndas (neutrum)\nExamples:\n\nder Tisch, der Tag\n\ndie Lampe, die Stadt\n\ndas Buch, das Kind',
            ),
            const LessonSlide(
              id: 'parts-slide-3',
              title: 'Verbs in basic form (Infinitiv)',
              text:
                  'Most verbs end with “-en” or “-n”.\nExamples:\n\ngehen, kommen, lernen, machen, arbeiten\nWhen you conjugate them, the ending changes:\n\nich gehe, du gehst, er/sie geht',
            ),
            const LessonSlide(
              id: 'parts-slide-4',
              title: 'Adjectives – describing words',
              text:
                  'Adjectives describe nouns:\n\nein großer Hund\n\neine kleine Wohnung\n\nein neues Auto\nAt A1 level, it’s enough to recognize them and use them in simple phrases.',
            ),
          ],
        ),
        LessonItem(
          id: 'hallo',
          title: 'Hallo',
          categoryId: 'beginner',
          description: 'Greetings for everyday practice.',
          slides: [
            const LessonSlide(
              id: 'hallo-slide-1',
              title: 'Basic greetings',
              text:
                  'Common ways to say hello:\n\nHallo!\n\nGuten Morgen! (morning)\n\nGuten Tag! (day / afternoon)\n\nGuten Abend! (evening)\n\nTschüss! / Auf Wiedersehen! (goodbye)',
            ),
            const LessonSlide(
              id: 'hallo-slide-2',
              title: 'Introducing yourself',
              text:
                  'Useful phrases:\n\nIch heiße …\n\nIch bin …\n\nIch komme aus …\n\nIch wohne in …\nExample:\n\n„Hallo, ich heiße Khaled. Ich komme aus … und wohne in Trier.“',
            ),
            const LessonSlide(
              id: 'hallo-slide-3',
              title: 'Asking “How are you?”',
              text:
                  'Wie geht es dir? (informal)\n\nWie geht es Ihnen? (formal)\nPossible answers:\n\nMir geht es gut.\n\nEs geht.\n\nNicht so gut.',
            ),
            const LessonSlide(
              id: 'hallo-slide-4',
              title: 'Polite words',
              text:
                  'Always useful:\n\nDanke! / Vielen Dank!\n\nBitte! (you’re welcome / please)\n\nEntschuldigung! (sorry / excuse me)\nThese small words make your German sound friendly.',
            ),
          ],
        ),
        LessonItem(
          id: 'all_about_german',
          title: 'All about German',
          categoryId: 'beginner',
          description: 'Culture, words, and basics to keep learning.',
          slides: [
            const LessonSlide(
              id: 'german-slide-1',
              title: 'Where is German spoken?',
              text:
                  'German is spoken in:\n\nGermany (Deutschland)\n\nAustria (Österreich)\n\nSwitzerland (Schweiz – part of the country)\nand in some other regions in Europe.\nThere are different accents and dialects, but the standard language is called “Hochdeutsch”.',
            ),
            const LessonSlide(
              id: 'german-slide-2',
              title: 'Formal vs informal “you”',
              text:
                  'German has two forms of “you”:\n\ndu (informal, for friends, family)\n\nSie (formal, polite, for strangers / official situations)\nExample:\n\nWie geht es dir? (du)\n\nWie geht es Ihnen? (Sie)',
            ),
            const LessonSlide(
              id: 'german-slide-3',
              title: 'Word order – basic idea',
              text:
                  'In a simple main clause, the verb is usually in position 2:\n\nIch lerne Deutsch.\n\nHeute lerne ich Deutsch.\n\nMorgen gehe ich nach Berlin.\nYou don’t need all grammar rules now, but remember: the verb wants to be in position 2.',
            ),
            const LessonSlide(
              id: 'german-slide-4',
              title: 'Don’t be afraid of long words',
              text:
                  'German loves long compound words:\n\ndie Straßenbahn (Straße + Bahn)\n\ndas Krankenhaus (krank + Haus)\n\ndie Haustür (Haus + Tür)\nTry to see them as small pieces glued together.\nThis makes them easier to understand and remember.',
            ),
          ],
        ),
      ],
    ),    LessonCategory(
      id: 'grammar',
      title: 'Grammar',
      description: 'Structure and syntax for every CEFR level.',
      lessons: [
        LessonItem(
          id: 'grammar_a1_personal_pronouns',
          title: 'A1 – Personal Pronouns',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_a1_personal_pronouns-slide-1',
              title: 'Pronouns',
              text:
                  'Pronouns replace nouns so we don’t repeat the same word.\n'
                  'ich = I\n'
                  'du = you\n'
                  'er = he\n'
                  'sie = she\n'
                  'es = it\n'
                  'wir = we\n'
                  'ihr = you all\n'
                  'sie = they\n'
                  'Sie = you (formal)',
            ),
            const LessonSlide(
              id: 'grammar_a1_personal_pronouns-slide-2',
              title: 'Formal Sie',
              text:
                  'Use Sie for strangers, teachers, officials.\n'
                  '“Wie heißen Sie?” / “Wo wohnen Sie?”',
            ),
            const LessonSlide(
              id: 'grammar_a1_personal_pronouns-slide-3',
              title: 'Practice',
              text:
                  'ich bin…\n'
                  'du bist…\n'
                  'er ist…\n'
                  'wir sind…\n'
                  'ihr seid…',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_a1_verb_conjugation',
          title: 'A1 – Verb Conjugation (Präsens)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_a1_verb_conjugation-slide-1',
              title: 'Endings',
              text:
                  'ich -e\n'
                  'du -st\n'
                  'er/sie/es -t\n'
                  'wir -en\n'
                  'ihr -t\n'
                  'sie/Sie -en',
            ),
            const LessonSlide(
              id: 'grammar_a1_verb_conjugation-slide-2',
              title: 'Examples',
              text:
                  'lernen → ich lerne, du lernst, er lernt…',
            ),
            const LessonSlide(
              id: 'grammar_a1_verb_conjugation-slide-3',
              title: 'Practice',
              text:
                  '“Ich wohne in Deutschland.”\n'
                  '“Du arbeitest viel.”',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_a1_verb_position',
          title: 'A1 – Verb Position (Main Clauses)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_a1_verb_position-slide-1',
              title: 'V2 Rule',
              text:
                  'Verb is always in position 2.\n'
                  'Ich lerne Deutsch.\n'
                  'Heute lerne ich Deutsch.',
            ),
            const LessonSlide(
              id: 'grammar_a1_verb_position-slide-2',
              title: 'Time-first',
              text: 'Heute gehe ich arbeiten.',
            ),
            const LessonSlide(
              id: 'grammar_a1_verb_position-slide-3',
              title: 'Wrong vs right',
              text:
                  '❌ Heute ich gehe…\n'
                  '✔️ Heute gehe ich…',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_a1_articles',
          title: 'A1 – Articles (der / die / das)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_a1_articles-slide-1',
              title: 'Genders',
              text:
                  'der = masculine\n'
                  'die = feminine\n'
                  'das = neuter',
            ),
            const LessonSlide(
              id: 'grammar_a1_articles-slide-2',
              title: 'Always learn article',
              text:
                  'Always learn:\n'
                  'der Hund\n'
                  'die Lampe\n'
                  'das Auto',
            ),
            const LessonSlide(
              id: 'grammar_a1_articles-slide-3',
              title: 'Tip',
              text: 'Use colors (blue/red/green).',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_a1_nominative',
          title: 'A1 – Nominative Case (Subject)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_a1_nominative-slide-1',
              title: 'Subject',
              text:
                  'The person/thing doing the action.\n'
                  'Der Hund läuft.\n'
                  'Die Frau arbeitet.',
            ),
            const LessonSlide(
              id: 'grammar_a1_nominative-slide-2',
              title: 'Articles',
              text:
                  'Masc = der\n'
                  'Fem = die\n'
                  'Neut = das\n'
                  'Plural = die',
            ),
            const LessonSlide(
              id: 'grammar_a1_nominative-slide-3',
              title: 'Practice',
              text:
                  '“Der Mann kommt.”\n'
                  '“Die Kinder spielen.”',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_a1_accusative',
          title: 'A1 – Accusative Case (Direct Object)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_a1_accusative-slide-1',
              title: 'Object',
              text:
                  'Ich sehe den Mann.\n'
                  'Ich habe einen Hund.',
            ),
            const LessonSlide(
              id: 'grammar_a1_accusative-slide-2',
              title: 'Article change',
              text: 'Only masculine changes:\n'
                  'der → den',
            ),
            const LessonSlide(
              id: 'grammar_a1_accusative-slide-3',
              title: 'Practice',
              text:
                  'Ich nehme das Buch.\n'
                  'Wir besuchen die Oma.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_a1_questions',
          title: 'A1 – Questions (W-Questions & Yes/No)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_a1_questions-slide-1',
              title: 'W Question words',
              text:
                  'Wer, Was, Wo, Wohin, Woher, Wie, Warum…',
            ),
            const LessonSlide(
              id: 'grammar_a1_questions-slide-2',
              title: 'Structure',
              text:
                  'W + Verb + Subject\n'
                  '“Wo wohnst du?”',
            ),
            const LessonSlide(
              id: 'grammar_a1_questions-slide-3',
              title: 'Yes/No Questions',
              text: 'Verb first:\n'
                  '“Hast du Zeit?”',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_a1_separable_verbs',
          title: 'A1 – Separable Verbs',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_a1_separable_verbs-slide-1',
              title: 'Rule',
              text: 'Prefix goes to the end.\n'
                  'Ich rufe dich an.',
            ),
            const LessonSlide(
              id: 'grammar_a1_separable_verbs-slide-2',
              title: 'Examples',
              text: 'aufstehen → Ich stehe auf.',
            ),
            const LessonSlide(
              id: 'grammar_a1_separable_verbs-slide-3',
              title: 'Practice',
              text: 'Ich mache die Tür zu.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_a1_modal_verbs_basic',
          title: 'A1 – Modal Verbs (basic)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_a1_modal_verbs_basic-slide-1',
              title: 'Modals',
              text:
                  'können — can\n'
                  'müssen — must\n'
                  'wollen — want',
            ),
            const LessonSlide(
              id: 'grammar_a1_modal_verbs_basic-slide-2',
              title: 'Structure',
              text:
                  'Modal = position 2\n'
                  'Main verb = end\n'
                  'Ich kann Deutsch sprechen.',
            ),
            const LessonSlide(
              id: 'grammar_a1_modal_verbs_basic-slide-3',
              title: 'Practice',
              text: 'Wir müssen arbeiten.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_a1_negation',
          title: 'A1 – Negation (nicht / kein)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_a1_negation-slide-1',
              title: 'nicht',
              text:
                  'Negates verbs & adjectives.\n'
                  'Ich komme nicht.\n'
                  'Das ist nicht gut.',
            ),
            const LessonSlide(
              id: 'grammar_a1_negation-slide-2',
              title: 'kein',
              text: 'Negates nouns.\n'
                  'Ich habe kein Auto.',
            ),
            const LessonSlide(
              id: 'grammar_a1_negation-slide-3',
              title: 'Rule',
              text: 'kein = negation of ein.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_a2_dative',
          title: 'A2 – Dative Case',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_a2_dative-slide-1',
              title: 'What is Dative?',
              text:
                  'Dative shows to whom / for whom something happens.\n\n'
                  'Examples:\n'
                  'Ich gebe dem Mann das Buch.\n'
                  'Wir helfen der Frau.\n\n'
                  'The person who receives something = Dative.',
            ),
            const LessonSlide(
              id: 'grammar_a2_dative-slide-2',
              title: 'Dative articles',
              text:
                  'Gender\tNominative\tDative\n'
                  'Masc\tder\t dem\n'
                  'Fem\tdie\t der\n'
                  'Neut\tdas\t dem\n'
                  'Plural\tdie\t den (+n on noun)\n\n'
                  'Examples:\n'
                  'Ich spreche mit dem Freund.\n'
                  'Ich danke der Lehrerin.\n'
                  'Ich fahre mit dem Auto.\n'
                  'Ich spiele mit den Kindern.',
            ),
            const LessonSlide(
              id: 'grammar_a2_dative-slide-3',
              title: 'Dative verbs & prepositions',
              text:
                  'Common Dative verbs:\n'
                  'helfen, danken, gefallen, gehören\n\n'
                  'Common Dative prepositions (always Dativ):\n'
                  'mit, nach, bei, seit, von, zu\n\n'
                  'Examples:\n'
                  'Ich gehe zu dem Arzt.\n'
                  'Wir fahren mit der Bahn.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_a2_two_way_prepositions',
          title: 'A2 – Two-way Prepositions (Wechselpräpositionen)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_a2_two_way_prepositions-slide-1',
              title: 'Idea',
              text:
                  'These prepositions can take Akkusativ (movement) or Dativ (location).\n\n'
                  'List:\n'
                  'in, an, auf, neben, hinter, über, unter, vor, zwischen',
            ),
            const LessonSlide(
              id: 'grammar_a2_two_way_prepositions-slide-2',
              title: 'Movement vs Location',
              text:
                  'Movement → Akkusativ (Wohin?)\n'
                  'Location → Dativ (Wo?)\n\n'
                  'Examples:\n'
                  'Ich gehe in die Stadt. (movement)\n'
                  'Ich bin in der Stadt. (location)\n\n'
                  'Ich lege das Buch auf den Tisch. (movement)\n'
                  'Das Buch liegt auf dem Tisch. (location)',
            ),
            const LessonSlide(
              id: 'grammar_a2_two_way_prepositions-slide-3',
              title: 'Simple test',
              text:
                  'Ask yourself:\n'
                  '“Wohin?” → use Akkusativ\n'
                  '“Wo?” → use Dativ',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_a2_perfekt',
          title: 'A2 – Perfekt (Present Perfect)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_a2_perfekt-slide-1',
              title: 'What is Perfekt?',
              text:
                  'Perfekt = past tense in spoken German.\n\n'
                  'Structure:\n'
                  'haben/sein + Partizip II\n\n'
                  'Ich habe gearbeitet.\n'
                  'Er ist gekommen.',
            ),
            const LessonSlide(
              id: 'grammar_a2_perfekt-slide-2',
              title: 'haben vs sein',
              text:
                  'Use sein with:\n\n'
                  'movement: gehen, kommen, fahren, laufen\n'
                  'change of state: aufstehen, einschlafen\n\n'
                  'Examples:\n'
                  'Ich bin gekommen.\n'
                  'Sie ist aufgestanden.\n\n'
                  'Other verbs usually use haben:\n'
                  'Ich habe gelernt.\n'
                  'Wir haben gespielt.',
            ),
            const LessonSlide(
              id: 'grammar_a2_perfekt-slide-3',
              title: 'Building Partizip II',
              text:
                  'Regular verbs: ge + stem + t\n'
                  'machen → gemacht\n'
                  'lernen → gelernt\n\n'
                  'Irregular – must be memorized:\n'
                  'sehen → gesehen\n'
                  'kommen → gekommen\n'
                  'gehen → gegangen',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_a2_comparative_superlative',
          title: 'A2 – Comparative & Superlative',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_a2_comparative_superlative-slide-1',
              title: 'Comparative (more …)',
              text:
                  'Adjective + -er:\n\n'
                  'klein → kleiner\n'
                  'schnell → schneller\n'
                  'teuer → teurer\n\n'
                  'Sentence:\n'
                  'Maria ist größer als Paul.',
            ),
            const LessonSlide(
              id: 'grammar_a2_comparative_superlative-slide-2',
              title: 'Superlative (the most …)',
              text:
                  'am + Adjective + -sten:\n\n'
                  'schnell → am schnellsten\n'
                  'groß → am größten\n'
                  'gut → am besten\n\n'
                  'Example:\n'
                  'Deutsch ist für mich am interessantesten.',
            ),
            const LessonSlide(
              id: 'grammar_a2_comparative_superlative-slide-3',
              title: 'Important irregular forms',
              text:
                  'gut → besser → am besten\n'
                  'viel → mehr → am meisten\n'
                  'gern → lieber → am liebsten',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_a2_reflexive_verbs',
          title: 'A2 – Reflexive Verbs',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_a2_reflexive_verbs-slide-1',
              title: 'Reflexive idea',
              text:
                  'The action goes back to the subject.\n\n'
                  'Ich wasche mich.\n'
                  'Du freust dich.',
            ),
            const LessonSlide(
              id: 'grammar_a2_reflexive_verbs-slide-2',
              title: 'Reflexive pronouns (Akkusativ)',
              text:
                  'ich → mich\n'
                  'du → dich\n'
                  'er/sie/es → sich\n'
                  'wir → uns\n'
                  'ihr → euch\n'
                  'sie/Sie → sich',
            ),
            const LessonSlide(
              id: 'grammar_a2_reflexive_verbs-slide-3',
              title: 'Common reflexive verbs',
              text:
                  'sich freuen\n'
                  'sich treffen\n'
                  'sich erinnern\n'
                  'sich setzen\n'
                  'sich vorstellen\n\n'
                  'Examples:\n'
                  'Ich freue mich auf das Wochenende.\n'
                  'Wir treffen uns um 8 Uhr.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_a2_modal_verbs_full',
          title: 'A2 – Modal Verbs – full set',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_a2_modal_verbs_full-slide-1',
              title: 'List',
              text:
                  'können – can\n'
                  'müssen – must\n'
                  'wollen – want\n'
                  'dürfen – may / allowed\n'
                  'sollen – should\n'
                  'mögen / möchte – like / would like',
            ),
            const LessonSlide(
              id: 'grammar_a2_modal_verbs_full-slide-2',
              title: 'Structure',
              text:
                  'Modal verb = position 2\n'
                  'Main verb = infinitive at the end:\n\n'
                  'Ich kann schwimmen.\n'
                  'Wir dürfen hier nicht rauchen.\n'
                  'Er will heute nicht kommen.',
            ),
            const LessonSlide(
              id: 'grammar_a2_modal_verbs_full-slide-3',
              title: '“möchte”',
              text:
                  'möchte = polite “want”\n\n'
                  'Ich möchte Kaffee.\n'
                  'Möchtest du mitkommen?',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_a2_subordinate_clauses',
          title: 'A2 – Subordinate Clauses (weil / dass)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_a2_subordinate_clauses-slide-1',
              title: 'weil (because)',
              text:
                  'Subordinate clause with weil: verb goes to the end.\n\n'
                  'Ich bleibe zu Hause, weil ich müde bin.\n'
                  'Wir gehen essen, weil wir Hunger haben.',
            ),
            const LessonSlide(
              id: 'grammar_a2_subordinate_clauses-slide-2',
              title: 'dass (that)',
              text:
                  'Use dass to connect statements:\n\n'
                  'Er sagt, dass er keine Zeit hat.\n'
                  'Ich glaube, dass Deutsch interessant ist.',
            ),
            const LessonSlide(
              id: 'grammar_a2_subordinate_clauses-slide-3',
              title: 'Word order rule',
              text:
                  'Main clause: verb = position 2\n'
                  'weil/dass clause: verb at the end\n\n'
                  'Ich lerne Deutsch, weil ich in Deutschland lebe.\n'
                  'Ich denke, dass du Recht hast.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_a2_time_order',
          title: 'A2 – Time Order (Temporal first)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_a2_time_order-slide-1',
              title: 'Time at the beginning',
              text:
                  'If you start with a time expression, verb is still in position 2.\n\n'
                  'Heute gehe ich arbeiten.\n'
                  'Morgen fahre ich nach Berlin.',
            ),
            const LessonSlide(
              id: 'grammar_a2_time_order-slide-2',
              title: 'Useful pattern',
              text:
                  'TIME → VERB → SUBJECT → REST\n\n'
                  'Gestern habe ich Pizza gegessen.\n'
                  'Am Wochenende fahren wir nach Köln.',
            ),
            const LessonSlide(
              id: 'grammar_a2_time_order-slide-3',
              title: 'Common time words',
              text:
                  'gestern\n'
                  'heute\n'
                  'morgen\n'
                  'am Wochenende\n'
                  'im Januar\n'
                  'jeden Tag',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_a2_possessive_pronouns',
          title: 'A2 – Possessive Pronouns (full set)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_a2_possessive_pronouns-slide-1',
              title: 'Forms',
              text:
                  'mein – my\n'
                  'dein – your (sg)\n'
                  'sein – his\n'
                  'ihr – her\n'
                  'unser – our\n'
                  'euer – your (pl)\n'
                  'ihr – their\n'
                  'Ihr – your (formal)',
            ),
            const LessonSlide(
              id: 'grammar_a2_possessive_pronouns-slide-2',
              title: 'Examples',
              text:
                  'Das ist mein Auto.\n'
                  'Ist das dein Hund?\n'
                  'Er liest sein Buch.\n'
                  'Sie verkauft ihr Haus.\n'
                  'Das ist unser Lehrer.',
            ),
            const LessonSlide(
              id: 'grammar_a2_possessive_pronouns-slide-3',
              title: 'Plural & polite',
              text:
                  'Sind das eure Kinder?\n'
                  'Ist das Ihr Wagen, Frau Müller?',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_a2_adjective_endings_basic',
          title: 'A2 – Adjective Endings (basic)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_a2_adjective_endings_basic-slide-1',
              title: 'After ein/kein/mein (Nominativ)',
              text:
                  'Very simplified A2 view:\n\n'
                  'ein kleiner Mann\n'
                  'eine kleine Frau\n'
                  'ein kleines Kind\n\n'
                  'kein kleiner Mann\n'
                  'keine kleine Frau\n'
                  'kein kleines Kind',
            ),
            const LessonSlide(
              id: 'grammar_a2_adjective_endings_basic-slide-2',
              title: 'Accusative masculine',
              text:
                  'Only masculine changes:\n\n'
                  'Ich sehe einen kleinen Mann.\n'
                  'Ich habe keinen kleinen Hund.',
            ),
            const LessonSlide(
              id: 'grammar_a2_adjective_endings_basic-slide-3',
              title: 'Strategy',
              text:
                  'At A2, you don’t need full tables.\n'
                  'Focus on:\n\n'
                  'Masculine forms (ein/kein/mein…)\n'
                  'Learn with real examples instead of theory.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_b1_praeteritum',
          title: 'B1 – Präteritum (Simple Past)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_b1_praeteritum-slide-1',
              title: 'What is Präteritum?',
              text:
                  'A past tense mostly used:\n\n'
                  'in writing (books, news, reports)\n\n'
                  'in speech mostly for: sein, haben, modal verbs\n\n'
                  'Examples:\n'
                  'Ich war müde.\n'
                  'Wir hatten keine Zeit.',
            ),
            const LessonSlide(
              id: 'grammar_b1_praeteritum-slide-2',
              title: 'Common forms',
              text:
                  'sein → war, warst, war, waren, wart, waren\n'
                  'haben → hatte, hattest, hatte…\n\n'
                  'Modal verbs:\n'
                  'können → konnte\n'
                  'müssen → musste\n'
                  'wollen → wollte\n'
                  'dürfen → durfte\n'
                  'sollen → sollte',
            ),
            const LessonSlide(
              id: 'grammar_b1_praeteritum-slide-3',
              title: 'Usage examples',
              text:
                  'Ich war gestern zu Hause.\n'
                  'Wir hatten viel Arbeit.\n'
                  'Er konnte nicht kommen.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_b1_konjunktiv_ii',
          title: 'B1 – Konjunktiv II (würde-Form)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_b1_konjunktiv_ii-slide-1',
              title: 'What is it?',
              text:
                  'Used for polite requests, wishes, unreal situations.\n\n'
                  'Key structure:\n'
                  'würde + infinitive',
            ),
            const LessonSlide(
              id: 'grammar_b1_konjunktiv_ii-slide-2',
              title: 'Examples',
              text:
                  'Ich würde gern kommen.\n'
                  'Könntest du mir bitte helfen?\n'
                  'Ich würde das nicht machen.',
            ),
            const LessonSlide(
              id: 'grammar_b1_konjunktiv_ii-slide-3',
              title: 'When to use?',
              text:
                  'polite → „Ich würde gerne bezahlen.“\n\n'
                  'unreal → „Ich würde mehr reisen, wenn ich Geld hätte.“',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_b1_relative_clauses',
          title: 'B1 – Relative Clauses (Relativsätze)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_b1_relative_clauses-slide-1',
              title: 'Idea',
              text:
                  'Connect two sentences by referring to a noun.\n\n'
                  'Der Mann, der dort steht, ist mein Lehrer.\n'
                  'Die Frau, die ich kenne, wohnt hier.',
            ),
            const LessonSlide(
              id: 'grammar_b1_relative_clauses-slide-2',
              title: 'Relative pronouns',
              text:
                  'Gender\tNominativ\tAkkusativ\tDativ\n'
                  'Masc\tder\tden\tdem\n'
                  'Fem\tdie\tdie\tder\n'
                  'Neut\tdas\tdas\tdem\n'
                  'Plural\tdie\tdie\tdenen',
            ),
            const LessonSlide(
              id: 'grammar_b1_relative_clauses-slide-3',
              title: 'Verb at the end',
              text: 'In a relative clause, the verb always goes to the end.\n\n'
                  'Das Auto, das ich gekauft habe, ist teuer.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_b1_passive_vorgangspassiv',
          title: 'B1 – Passive Voice (Vorgangspassiv)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_b1_passive_vorgangspassiv-slide-1',
              title: 'Form',
              text:
                  'werden + Partizip II\n\n'
                  'Beispiel:\n'
                  'Das Brot wird gebacken.\n'
                  'Der Tisch wird gemacht.',
            ),
            const LessonSlide(
              id: 'grammar_b1_passive_vorgangspassiv-slide-2',
              title: 'Tenses',
              text:
                  'Present: wird + Partizip II\n'
                  'Past: wurde + Partizip II\n\n'
                  'Beispiele:\n'
                  'Der Fehler wird korrigiert.\n'
                  'Der Brief wurde geschrieben.',
            ),
            const LessonSlide(
              id: 'grammar_b1_passive_vorgangspassiv-slide-3',
              title: 'Focus',
              text: 'Focus is on the action, not the person doing it.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_b1_reflexive_advanced',
          title: 'B1 – Reflexive Verbs (advanced)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_b1_reflexive_advanced-slide-1',
              title: 'Reflexive + prepositions',
              text:
                  'Some reflexive verbs need fixed prepositions:\n\n'
                  'sich freuen auf / über\n'
                  'sich interessieren für\n'
                  'sich erinnern an',
            ),
            const LessonSlide(
              id: 'grammar_b1_reflexive_advanced-slide-2',
              title: 'Examples',
              text:
                  'Ich freue mich auf das Wochenende.\n'
                  'Sie erinnert sich an die Reise.\n'
                  'Wir interessieren uns für Musik.',
            ),
            const LessonSlide(
              id: 'grammar_b1_reflexive_advanced-slide-3',
              title: 'Reflexive in Dativ',
              text:
                  'If the verb also has an object, reflexive pronoun becomes dative:\n\n'
                  'Ich wasche mir die Hände.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_b1_prepositional_verbs',
          title: 'B1 – Prepositional Verbs',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_b1_prepositional_verbs-slide-1',
              title: 'Definition',
              text:
                  'Verbs that must be used with a specific preposition.\n\n'
                  'Examples:\n'
                  'warten auf\n'
                  'denken an\n'
                  'fragen nach\n'
                  'teilnehmen an',
            ),
            const LessonSlide(
              id: 'grammar_b1_prepositional_verbs-slide-2',
              title: 'Example sentences',
              text:
                  'Ich warte auf den Bus.\n'
                  'Ich denke an dich.\n'
                  'Wir nehmen an dem Kurs teil.',
            ),
            const LessonSlide(
              id: 'grammar_b1_prepositional_verbs-slide-3',
              title: 'Tip',
              text: 'Memorize verb + preposition as one unit.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_b1_indirect_questions',
          title: 'B1 – Indirect Questions (indirekte Fragen)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_b1_indirect_questions-slide-1',
              title: 'Idea',
              text:
                  'Used when you don’t ask directly.\n\n'
                  'Example:\n'
                  '„Wo wohnst du?“ → direct\n'
                  '„Kannst du mir sagen, wo du wohnst?“ → indirect',
            ),
            const LessonSlide(
              id: 'grammar_b1_indirect_questions-slide-2',
              title: 'Structure',
              text:
                  'Use question word + verb at the end.\n\n'
                  'Ich weiß nicht, wann er kommt.\n'
                  'Sie fragt, wo ich bin.',
            ),
            const LessonSlide(
              id: 'grammar_b1_indirect_questions-slide-3',
              title: 'Yes/No',
              text: 'If the original question is yes/no, use ob:\n\n'
                  'Er möchte wissen, ob du heute kommst.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_b1_word_order_long',
          title: 'B1 – Word Order in Longer Sentences',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_b1_word_order_long-slide-1',
              title: 'Important rule',
              text:
                  'Main clause: verb in position 2\n'
                  'Subordinate clause: verb at the end',
            ),
            const LessonSlide(
              id: 'grammar_b1_word_order_long-slide-2',
              title: 'Sentence chain',
              text: 'Ich glaube, dass er kommt, weil er Zeit hat.',
            ),
            const LessonSlide(
              id: 'grammar_b1_word_order_long-slide-3',
              title: 'Time-Manner-Place (TMP)',
              text:
                  'German prefers this order:\n\n'
                  'Time → Manner → Place\n\n'
                  'Ich fahre morgen mit dem Bus nach Berlin.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_b1_adjective_dative',
          title: 'B1 – Adjective Endings (Dative)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_b1_adjective_dative-slide-1',
              title: 'Dative forms with articles',
              text:
                  'dem kleinen Mann\n'
                  'der kleinen Frau\n'
                  'dem kleinen Kind\n'
                  'den kleinen Kindern\n\n'
                  '(+n on noun)',
            ),
            const LessonSlide(
              id: 'grammar_b1_adjective_dative-slide-2',
              title: 'Examples',
              text:
                  'Ich spreche mit dem netten Lehrer.\n'
                  'Wir helfen der alten Frau.',
            ),
            const LessonSlide(
              id: 'grammar_b1_adjective_dative-slide-3',
              title: 'Tip',
              text: 'Learn patterns, not full tables at once.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_b1_genitive_basic',
          title: 'B1 – Genitive (basic)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_b1_genitive_basic-slide-1',
              title: 'Idea',
              text:
                  'Genitive shows possession.\n\n'
                  'Das Auto des Mannes.\n'
                  '(= the man’s car)',
            ),
            const LessonSlide(
              id: 'grammar_b1_genitive_basic-slide-2',
              title: 'Articles',
              text:
                  'Gender\tGenitive\n'
                  'Masc\tdes (+s/es)\n'
                  'Neut\tdes (+s/es)\n'
                  'Fem\tder\n'
                  'Plural\tder',
            ),
            const LessonSlide(
              id: 'grammar_b1_genitive_basic-slide-3',
              title: 'Examples',
              text:
                  'Das Haus der Frau.\n'
                  'Die Tasche des Kindes.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_b2_konjunktiv_ii_full',
          title: 'B2 – Konjunktiv II (full forms)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_b2_konjunktiv_ii_full-slide-1',
              title: 'What is Konjunktiv II?',
              text:
                  'Expresses:\n\n'
                  'unreal situations\n'
                  'polite requests\n'
                  'wishes\n'
                  'hypotheses',
            ),
            const LessonSlide(
              id: 'grammar_b2_konjunktiv_ii_full-slide-2',
              title: 'Forms without “würde”',
              text:
                  'haben → hätte\n'
                  'sein → wäre\n'
                  'können → könnte\n'
                  'müssen → müsste\n'
                  'dürfen → dürfte\n'
                  'wollen → wollte\n'
                  'sollen → sollte\n\n'
                  'These are the most common real Konjunktiv II forms.',
            ),
            const LessonSlide(
              id: 'grammar_b2_konjunktiv_ii_full-slide-3',
              title: 'Examples',
              text:
                  'Ich wäre gern reich.\n'
                  'Er hätte mehr Zeit, wenn er weniger arbeitet.\n'
                  'Könntest du mir bitte helfen?',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_b2_passive_zustandspassiv',
          title: 'B2 – Passive Voice (Zustandspassiv)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_b2_passive_zustandspassiv-slide-1',
              title: 'Idea',
              text:
                  'Zustandspassiv describes a state caused by a previous action.\n\n'
                  'Form:\n'
                  'sein + Partizip II',
            ),
            const LessonSlide(
              id: 'grammar_b2_passive_zustandspassiv-slide-2',
              title: 'Examples',
              text:
                  'Der Tisch ist gedeckt. (The table is set.)\n'
                  'Die Tür ist geschlossen.\n'
                  'Das Auto ist repariert.',
            ),
            const LessonSlide(
              id: 'grammar_b2_passive_zustandspassiv-slide-3',
              title: 'Difference from Vorgangspassiv',
              text:
                  'Vorgangspassiv = action in progress (wird gemacht)\n\n'
                  'Zustandspassiv = result/state (ist gemacht)',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_b2_nominalisation',
          title: 'B2 – Nominalisation',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_b2_nominalisation-slide-1',
              title: 'Idea',
              text:
                  'Turn verbs/adjectives into nouns for formal language.\n\n'
                  'lernen → das Lernen\n'
                  'wichtig → die Wichtigkeit\n'
                  'ankommen → die Ankunft',
            ),
            const LessonSlide(
              id: 'grammar_b2_nominalisation-slide-2',
              title: 'Why use it?',
              text:
                  'More formal\n'
                  'Common in academic texts\n'
                  'Used heavily in B2–C1 exams',
            ),
            const LessonSlide(
              id: 'grammar_b2_nominalisation-slide-3',
              title: 'Examples in sentences',
              text:
                  'Beim Lernen höre ich Musik.\n'
                  'Nach der Ankunft gingen wir essen.\n'
                  'Trotz der Wichtigkeit des Themas…',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_b2_advanced_connectors',
          title: 'B2 – Advanced Connectors',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_b2_advanced_connectors-slide-1',
              title: 'Adding contrast',
              text:
                  'jedoch – however\n'
                  'dennoch – nevertheless\n'
                  'trotzdem – despite that\n\n'
                  'Example:\n'
                  'Er ist müde, dennoch arbeitet er weiter.',
            ),
            const LessonSlide(
              id: 'grammar_b2_advanced_connectors-slide-2',
              title: 'Cause & effect',
              text:
                  'folglich – consequently\n'
                  'deshalb – therefore\n'
                  'insofern – in this respect\n\n'
                  'Example:\n'
                  'Es regnet stark, folglich bleiben wir zu Hause.',
            ),
            const LessonSlide(
              id: 'grammar_b2_advanced_connectors-slide-3',
              title: 'Time & relation',
              text:
                  'während – while\n'
                  'seitdem – since (time)\n'
                  'sobald – as soon as',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_b2_infinitive_zu',
          title: 'B2 – Infinitive Clauses with „zu“',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_b2_infinitive_zu-slide-1',
              title: 'Structure',
              text:
                  'zu + infinitive at the end\n\n'
                  'Examples:\n'
                  'Ich habe vergessen, das Licht auszumachen.\n'
                  'Es ist schwer, früh aufzustehen.',
            ),
            const LessonSlide(
              id: 'grammar_b2_infinitive_zu-slide-2',
              title: 'With “um … zu”',
              text: 'Purpose:\n'
                  'Ich lerne Deutsch, um in Deutschland zu arbeiten.',
            ),
            const LessonSlide(
              id: 'grammar_b2_infinitive_zu-slide-3',
              title: 'With “ohne … zu” and “anstatt … zu”',
              text:
                  'ohne … zu → without doing\n'
                  'Er geht, ohne mich zu fragen.\n\n'
                  'anstatt … zu → instead of\n'
                  'Er schaut Netflix, anstatt zu arbeiten.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_b2_participle_adjective',
          title: 'B2 – Participle as Adjective (Partizip I/II)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_b2_participle_adjective-slide-1',
              title: 'Partizip I (…end)',
              text:
                  'Expresses an ongoing action.\n\n'
                  'Example:\n'
                  'der laufende Mann\n'
                  'die schlafende Katze',
            ),
            const LessonSlide(
              id: 'grammar_b2_participle_adjective-slide-2',
              title: 'Partizip II (…t/ge…t/en)',
              text:
                  'Expresses result.\n\n'
                  'Example:\n'
                  'das geöffnete Fenster\n'
                  'die geschriebene Nachricht',
            ),
            const LessonSlide(
              id: 'grammar_b2_participle_adjective-slide-3',
              title: 'In sentences',
              text:
                  'Ich sehe den rennenden Junge.\n'
                  'Die vergessene Tasche lag auf dem Tisch.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_b2_reported_speech',
          title: 'B2 – Reported Speech (indirekte Rede)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_b2_reported_speech-slide-1',
              title: 'Idea',
              text:
                  'Repeat what someone said without quoting directly.\n\n'
                  'Er sagt: „Ich komme morgen.“\n'
                  '→ Er sagt, er komme morgen. (formal)\n'
                  '→ Er sagt, er kommt morgen. (modern spoken)',
            ),
            const LessonSlide(
              id: 'grammar_b2_reported_speech-slide-2',
              title: 'Using “dass”',
              text: 'Informal / common:\n'
                  'Er sagt, dass er morgen kommt.',
            ),
            const LessonSlide(
              id: 'grammar_b2_reported_speech-slide-3',
              title: 'Tenses shift',
              text: 'Ich werde kommen → Er sagt, dass er kommen werde.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_b2_complex_relative',
          title: 'B2 – Complex Relative Clauses',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_b2_complex_relative-slide-1',
              title: 'Advanced pronouns',
              text:
                  'denen, dessen, deren\n\n'
                  'Examples:\n'
                  'Die Leute, deren Auto gestohlen wurde…\n'
                  'Das Buch, dessen Autor ich kenne…',
            ),
            const LessonSlide(
              id: 'grammar_b2_complex_relative-slide-2',
              title: 'Nested clauses',
              text: 'Ich kenne den Mann, der sagte, dass er helfen könne.',
            ),
            const LessonSlide(
              id: 'grammar_b2_complex_relative-slide-3',
              title: 'Tips',
              text:
                  'verb always at END\n\n'
                  'pronoun must agree with the noun it refers to, not the one next to it',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_b2_adjective_genitive',
          title: 'B2 – Adjective Endings in Genitive',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_b2_adjective_genitive-slide-1',
              title: 'Genitive article system',
              text:
                  'des großen Mannes\n'
                  'der schönen Frau\n'
                  'des neuen Hauses\n'
                  'der kleinen Kinder',
            ),
            const LessonSlide(
              id: 'grammar_b2_adjective_genitive-slide-2',
              title: 'Rule',
              text:
                  'Masculine & neuter: add -en\n'
                  'Feminine & plural: also -en\n\n'
                  'Genitive is simple: always -en.',
            ),
            const LessonSlide(
              id: 'grammar_b2_adjective_genitive-slide-3',
              title: 'Examples',
              text:
                  'Der Titel des neuen Buches ist interessant.\n'
                  'Die Farbe der großen Wohnung gefällt mir.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_b2_hypothetical_structures',
          title: 'B2 – Hypothetical Structures',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_b2_hypothetical_structures-slide-1',
              title: 'If-clauses',
              text:
                  'Wenn ich Zeit hätte, würde ich reisen.\n'
                  'Wenn er Geld hätte, könnte er ein Auto kaufen.',
            ),
            const LessonSlide(
              id: 'grammar_b2_hypothetical_structures-slide-2',
              title: 'Without “wenn”',
              text:
                  'Hätte ich Zeit, würde ich reisen.\n'
                  'Wäre es warm, würden wir schwimmen gehen.',
            ),
            const LessonSlide(
              id: 'grammar_b2_hypothetical_structures-slide-3',
              title: 'Unreal past',
              text:
                  'Wenn ich das gewusst hätte, hätte ich es anders gemacht.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_c1_konjunktiv_i',
          title: 'C1 – Konjunktiv I (formal reported speech)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_c1_konjunktiv_i-slide-1',
              title: 'What is Konjunktiv I?',
              text:
                  'Used in newspapers, news, reports, academic texts to show reported speech without confirming if it’s true.\n\n'
                  'Example:\n'
                  'Er sagt: „Ich komme morgen.“\n'
                  '→ Er komme morgen.',
            ),
            const LessonSlide(
              id: 'grammar_c1_konjunktiv_i-slide-2',
              title: 'Forms',
              text:
                  'sein → sei\n'
                  'haben → habe\n'
                  'gehen → gehe\n'
                  'kommen → komme\n'
                  'arbeiten → arbeite\n\n'
                  'Pattern: stem + e (mostly)',
            ),
            const LessonSlide(
              id: 'grammar_c1_konjunktiv_i-slide-3',
              title: 'Usage',
              text:
                  'In writing:\n'
                  'Die Polizei berichtet, der Täter sei geflohen.\n'
                  'Die Zeitung schreibt, es gebe neue Hinweise.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_c1_nominalisation_advanced',
          title: 'C1 – Advanced Nominalisation',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_c1_nominalisation_advanced-slide-1',
              title: 'Why use it?',
              text:
                  'Makes writing formal, compact, academic.\n\n'
                  'statt:\n'
                  '„Wenn man überprüft, …“\n'
                  'Nominalisation:\n'
                  '„Bei der Überprüfung …“',
            ),
            const LessonSlide(
              id: 'grammar_c1_nominalisation_advanced-slide-2',
              title: 'Common patterns',
              text:
                  'Verb → Noun\n'
                  'ankommen → die Ankunft\n'
                  'entscheiden → die Entscheidung\n'
                  'verbessern → die Verbesserung\n\n'
                  'Adjective → Noun\n'
                  'wichtig → die Wichtigkeit\n'
                  'möglich → die Möglichkeit',
            ),
            const LessonSlide(
              id: 'grammar_c1_nominalisation_advanced-slide-3',
              title: 'Examples in sentences',
              text:
                  'Nach der Entscheidung wurde das Projekt gestartet.\n'
                  'Während der Untersuchung kamen neue Details ans Licht.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_c1_word_formation',
          title: 'C1 – Word Formation (prefixes, suffixes, compounds)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_c1_word_formation-slide-1',
              title: 'Common prefixes',
              text:
                  'ver-, be-, ent-, zer-, er-, über-, um-, unter-\n\n'
                  'They can change meaning heavily.\n'
                  'verstehen, versuchen, verbessern…',
            ),
            const LessonSlide(
              id: 'grammar_c1_word_formation-slide-2',
              title: 'Common suffixes',
              text:
                  '-heit, -keit, -ung, -schaft, -tion, -ismus, -ität\n\n'
                  'Example:\n'
                  'freundlich → Freundlichkeit\n'
                  'informieren → Information',
            ),
            const LessonSlide(
              id: 'grammar_c1_word_formation-slide-3',
              title: 'Compounds',
              text:
                  'German loves long compound nouns:\n\n'
                  'Datenschutzverordnung\n'
                  'Universitätsbibliothek\n'
                  'Krankenhausverwaltung\n\n'
                  'Meaning comes from combining pieces.',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_c1_complex_passive',
          title: 'C1 – Complex Passive Structures',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_c1_complex_passive-slide-1',
              title: 'Passiversatzformen',
              text:
                  'Instead of passive, German often uses:\n\n'
                  'sein + zu + infinitive\n'
                  'Die Aufgabe ist zu lösen. (= must be solved)',
            ),
            const LessonSlide(
              id: 'grammar_c1_complex_passive-slide-2',
              title: 'Alternative structures',
              text:
                  'bekommen + Partizip II\n'
                  'Ich bekam das Auto repariert. (= someone repaired it for me)',
            ),
            const LessonSlide(
              id: 'grammar_c1_complex_passive-slide-3',
              title: 'Using “lassen”',
              text:
                  'Ich lasse mein Auto reparieren.\n'
                  '→ I have my car repaired (by someone else).',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_c1_advanced_connectors',
          title: 'C1 – Advanced Connectors (folglich, demnach…)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_c1_advanced_connectors-slide-1',
              title: 'Logical connectors',
              text:
                  'folglich — consequently\n'
                  'demnach — accordingly\n'
                  'infolgedessen — as a consequence\n\n'
                  'Example:\n'
                  'Es gibt keine Beweise, folglich wird der Fall geschlossen.',
            ),
            const LessonSlide(
              id: 'grammar_c1_advanced_connectors-slide-2',
              title: 'Contrast connectors',
              text:
                  'dennoch — nevertheless\n'
                  'gleichwohl — nonetheless\n'
                  'jedoch — however',
            ),
            const LessonSlide(
              id: 'grammar_c1_advanced_connectors-slide-3',
              title: 'Academic connectors',
              text:
                  'hingegen — in contrast\n'
                  'zwar … aber — indeed … but',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_c1_inversion_focus',
          title: 'C1 – Inversion for Focus',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_c1_inversion_focus-slide-1',
              title: 'Idea',
              text:
                  'Putting adverbials first to emphasize information.\n\n'
                  'Gestern kam er spät.\n'
                  'Noch nie habe ich sowas gesehen.',
            ),
            const LessonSlide(
              id: 'grammar_c1_inversion_focus-slide-2',
              title: 'Rule',
              text:
                  'If the sentence doesn’t start with the subject, the verb must be directly second, and the subject moves.',
            ),
            const LessonSlide(
              id: 'grammar_c1_inversion_focus-slide-3',
              title: 'Uses',
              text:
                  'emphasize contrast\n'
                  'highlight time or condition\n'
                  'create sophisticated style (C1 writing)',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_c1_complex_sentences',
          title: 'C1 – Complex Sentence Structures',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_c1_complex_sentences-slide-1',
              title: 'Multiple clauses',
              text: 'Ich denke, dass er kommt, weil er sagte, dass er Zeit habe.',
            ),
            const LessonSlide(
              id: 'grammar_c1_complex_sentences-slide-2',
              title: 'Reduced clauses',
              text:
                  'statt:\n'
                  'Menschen, die arbeiten\n'
                  '→ arbeitende Menschen',
            ),
            const LessonSlide(
              id: 'grammar_c1_complex_sentences-slide-3',
              title: 'Participial constructions',
              text: 'Nachdem wir gegessen hatten → Nach dem Essen',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_c1_theme_rheme',
          title: 'C1 – Theme–Rheme and Information Structure',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_c1_theme_rheme-slide-1',
              title: 'Theme (old info)',
              text: 'Known information comes first.',
            ),
            const LessonSlide(
              id: 'grammar_c1_theme_rheme-slide-2',
              title: 'Rheme (new info)',
              text: 'New/surprising info comes later.',
            ),
            const LessonSlide(
              id: 'grammar_c1_theme_rheme-slide-3',
              title: 'Example',
              text: 'Das Problem (theme) wurde gestern gelöst durch ein Softwareupdate (rheme).',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_c1_full_adjective_endings',
          title: 'C1 – Full Adjective Endings (all cases)',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_c1_full_adjective_endings-slide-1',
              title: 'Idea',
              text:
                  'At C1 you must know:\n\n'
                  'strong declension\n'
                  'weak declension\n'
                  'mixed declension',
            ),
            const LessonSlide(
              id: 'grammar_c1_full_adjective_endings-slide-2',
              title: 'Rules (simplified)',
              text:
                  'With article → weak\n'
                  'Without article → strong',
            ),
            const LessonSlide(
              id: 'grammar_c1_full_adjective_endings-slide-3',
              title: 'Example set',
              text:
                  'ein neues Auto\n'
                  'das neue Auto\n'
                  'mit neuem Auto\n'
                  'ohne neues Auto',
            ),
          ],
        ),
        LessonItem(
          id: 'grammar_c1_academic_structures',
          title: 'C1 – Academic-style Structures',
          categoryId: 'grammar',
          slides: [
            const LessonSlide(
              id: 'grammar_c1_academic_structures-slide-1',
              title: 'Typical academic patterns',
              text:
                  'Es lässt sich feststellen, dass …\n'
                  'Es ist davon auszugehen, dass …\n'
                  'Im Folgenden wird gezeigt, dass …',
            ),
            const LessonSlide(
              id: 'grammar_c1_academic_structures-slide-2',
              title: 'Nominal style',
              text: 'statt: „weil man prüft“ → „aufgrund der Prüfung“',
            ),
            const LessonSlide(
              id: 'grammar_c1_academic_structures-slide-3',
              title: 'Avoid colloquial forms',
              text: 'Use formal connectors and passive structures.',
            ),
          ],
        ),
      ],
    ),
    LessonCategory(
      id: 'reading_listening',
      title: 'Reading & Listening',
      description: 'Practice comprehension with short stories.',
      lessons: [
        LessonItem(
          id: 'vorstellung',
          title: 'Vorstellung',
          categoryId: 'reading_listening',
          slides: [
            const LessonSlide(
              id: 'vorstellung-slide-1',
              title: 'Vorstellung',
              text:
                  'Mein Name ist Leyla. Ich komme aus der Türkei und wohne seit zwei Jahren in Deutschland. Ich bin 16 Jahre alt. Ich habe zwei Brüder: Ali ist 10 Jahre alt und Emre ist 20 Jahre alt. Wir wohnen mit unseren Eltern in einer Wohnung in der Nähe von Köln. Meine Mutter arbeitet im Krankenhaus und mein Vater ist Lehrer.\n\n'
                  'Ich höre gern Musik und ich mag Tiere. Wir haben einen kleinen Vogel und einen Hamster. Im Wohnzimmer steht ein Käfig mit beiden Tieren. Ich gehe gern zur Schule. Mein Lieblingsfach ist Deutsch. Sport mag ich auch, aber Geschichte finde ich schwierig.\n\n'
                  'Nach der Schule treffe ich oft meine Freundin im Stadtzentrum. Wir trinken manchmal Saft oder gehen ein bisschen spazieren. Am Samstag besuchen wir oft den Markt. Am Sonntag frühstücke ich lange mit meiner Familie. Am Nachmittag fahren wir manchmal an den Fluss und machen einen kurzen Spaziergang. Sonntag ist für mich ein ruhiger und schöner Tag.',
            ),
          ],
        ),
        LessonItem(
          id: 'weg_zur_post',
          title: 'Der Weg zur Post (Dialogue)',
          categoryId: 'reading_listening',
          slides: [
            const LessonSlide(
              id: 'weg_zur_post-slide-1',
              title: 'Der Weg zur Bäckerei',
              text:
                  'Sara ist neu in der Stadt. Sie möchte heute frisches Brot kaufen. Sie hat gehört, dass es eine gute Bäckerei in der Nähe gibt. Aber wo ist sie?\n'
                  'Sara hat die Adresse im Internet nicht gefunden. Sie muss jemanden fragen. Am Park sitzt eine junge Frau.\n\n'
                  '„Entschuldigung, wo ist bitte die Bäckerei?“, fragt Sara freundlich.\n'
                  '„In der Lindenstraße“, sagt die Frau.\n'
                  '„Muss ich mit dem Bus fahren oder kann ich zu Fuß gehen?“, fragt Sara.\n'
                  '„Sie können zu Fuß gehen. Es ist nicht weit“, antwortet die Frau.\n'
                  '„Wie komme ich zur Lindenstraße?“, fragt Sara weiter.\n'
                  '„Sie gehen zuerst geradeaus bis zur Apotheke. Dort biegen Sie links ab. Nach etwa 300 Metern sehen Sie eine große Kreuzung. Dort gehen Sie rechts. Das ist die Lindenstraße. Die Bäckerei ist auf der linken Seite.“\n'
                  '„Vielen Dank!“, sagt Sara und macht sich auf den Weg.',
            ),
          ],
        ),
        LessonItem(
          id: 'beim_arzt_dialogue',
          title: 'Gesundheit: Beim Arzt (Dialogue)',
          categoryId: 'reading_listening',
          slides: [
            const LessonSlide(
              id: 'beim_arzt_dialogue-slide-1',
              title: 'Gesundheit: Beim Arzt',
              text:
                  'Mina fühlt sich nicht gut. Sie geht zum Arzt.\n'
                  '„Was haben Sie?“, fragt der Arzt.\n'
                  '„Ich habe Bauchschmerzen und Kopfschmerzen“, sagt Mina.\n'
                  '„Seit wann haben Sie die Schmerzen?“ – „Seit zwei Tagen.“\n\n'
                  'Der Arzt tastet ihren Bauch ab, misst den Blutdruck und sieht in ihre Augen.\n'
                  '„Sie haben eine leichte Magenentzündung. Essen Sie viel Fast Food?“ – „Manchmal, ja.“\n'
                  '„Das ist nicht gut. Sie sollten im Moment leichte Kost essen. Haben Sie eine Lebensmittelunverträglichkeit?“ – „Nein, ich glaube nicht.“\n\n'
                  'Der Arzt schreibt ein Rezept. „Ich gebe Ihnen Tabletten. Sie holen die Medikamente bitte in der Apotheke. Nehmen Sie dreimal am Tag eine Tablette.“\n'
                  '„Kann ich morgen zur Schule gehen?“\n'
                  '„Nein, besser nicht. Sie müssen zwei Tage zu Hause bleiben und viel Wasser oder warmen Tee trinken. Am Wochenende können Sie wieder in die Schule gehen. Gute Besserung!“',
            ),
          ],
        ),
        LessonItem(
          id: 'in_der_schule',
          title: 'In der Schule',
          categoryId: 'reading_listening',
          slides: [
            const LessonSlide(
              id: 'in_der_schule-slide-1',
              title: 'In der Schule',
              text:
                  'Ich gehe meistens gern in die Schule. In meiner Klasse sind 22 Schüler. Es gibt viele Mädchen und auch ein paar Jungen. Unsere Lehrer sind freundlich und helfen uns oft. Neben mir sitzt meine Freundin Lina. Sie erklärt mir manchmal die Hausaufgaben. Jonas ist auch in meiner Klasse. Er ist sehr lustig.\n\n'
                  'In meinem Rucksack habe ich mein Mathebuch, ein Heft, zwei Bleistifte, einen Kugelschreiber und einen Spitzer. Für Kunst brauche ich Buntstifte und einen Pinsel. Für Mathe benutze ich ein Lineal. Mathe ist für mich schwierig, ich brauche immer etwas länger.\n\n'
                  'In der Pause sprechen wir miteinander und essen etwas. In der großen Pause gehen wir in den Schulhof. Dort spielen viele Kinder Basketball oder fangen. Die Pause ist immer schnell vorbei.\n\n'
                  'Ich mag nicht alle Fächer gleich gern. Mein Lieblingsfach ist Kunst, weil ich gerne male. Deutsch finde ich schwer, aber ich übe jeden Tag. Englisch macht mir Spaß. Auch Musik und Erdkunde mag ich sehr.\n\n'
                  'Vor den Ferien schreiben wir zwei Tests: einen in Mathe und einen in Deutsch. Ich hoffe, dass ich gute Noten bekomme.',
            ),
          ],
        ),
        LessonItem(
          id: 'juliana_deutschland',
          title: 'Sofia in Deutschland (Language Class)',
          categoryId: 'reading_listening',
          slides: [
            const LessonSlide(
              id: 'juliana_deutschland-slide-1',
              title: 'Sofia in Deutschland',
              text:
                  'Sofia kommt aus Madrid. Das ist die Hauptstadt von Spanien. In diesem Sommer macht sie einen Deutschkurs in Leipzig. Leipzig ist eine große Stadt im Osten von Deutschland.\n\n'
                  'Es gefällt ihr dort sehr gut. Der Unterricht beginnt um acht Uhr und endet um dreizehn Uhr. In ihrer Klasse sind außer Sofia noch 10 Schüler, fünf Mädchen und fünf Jungen. Sie kommen aus verschiedenen Städten in Spanien.\n\n'
                  'Sofias bester Freund Pablo macht auch einen Sprachkurs, aber in Stuttgart. Das liegt im Süden von Deutschland.\n\n'
                  'Nach dem Kurs möchten beide in Deutschland arbeiten. Sofia möchte Krankenschwester werden. Pablo möchte Informatiker werden, weil sein Vater auch Informatiker ist.\n\n'
                  'Sofia und Pablo bleiben insgesamt vier Wochen in Deutschland. Am Ende des Deutschkurses machen sie eine kleine Prüfung.',
            ),
          ],
        ),
        LessonItem(
          id: 'mein_tag',
          title: 'Mein Tag (Daily Routine)',
          categoryId: 'reading_listening',
          slides: [
            const LessonSlide(
              id: 'mein_tag-slide-1',
              title: 'Coming soon',
              text: 'Content will be added later.',
            ),
          ],
        ),
        LessonItem(
          id: 'meine_woche',
          title: 'Meine Woche',
          categoryId: 'reading_listening',
          slides: [
            const LessonSlide(
              id: 'meine_woche-slide-1',
              title: 'Coming soon',
              text: 'Content will be added later.',
            ),
          ],
        ),
        LessonItem(
          id: 'neu_in_der_stadt',
          title: 'Neu in der Stadt',
          categoryId: 'reading_listening',
          slides: [
            const LessonSlide(
              id: 'neu_in_der_stadt-slide-1',
              title: 'Coming soon',
              text: 'Content will be added later.',
            ),
          ],
        ),
        LessonItem(
          id: 'freizeit_plaene',
          title: 'Pläne für die Freizeit',
          categoryId: 'reading_listening',
          slides: [
            const LessonSlide(
              id: 'freizeit_plaene-slide-1',
              title: 'Coming soon',
              text: 'Content will be added later.',
            ),
          ],
        ),
        LessonItem(
          id: 'tagesablauf_anna',
          title: 'Tagesablauf (Anna’s Saturday Routine)',
          categoryId: 'reading_listening',
          slides: [
            const LessonSlide(
              id: 'tagesablauf_anna-slide-1',
              title: 'Coming soon',
              text: 'Content will be added later.',
            ),
          ],
        ),
        LessonItem(
          id: 'urlaub_berge',
          title: 'Urlaub in den Bergen',
          categoryId: 'reading_listening',
          slides: [
            const LessonSlide(
              id: 'urlaub_berge-slide-1',
              title: 'Coming soon',
              text: 'Content will be added later.',
            ),
          ],
        ),
        LessonItem(
          id: 'verkehrsmittel_overview',
          title: 'Verkehrsmittel (Overview)',
          categoryId: 'reading_listening',
          slides: [
            const LessonSlide(
              id: 'verkehrsmittel_overview-slide-1',
              title: 'Coming soon',
              text: 'Content will be added later.',
            ),
          ],
        ),
      ],
    ),
    const LessonCategory(
      id: 'exam',
      title: 'Exam Practice',
      description: 'Targeted drills for exams (A1, A2).',
    ),
  ];

}
