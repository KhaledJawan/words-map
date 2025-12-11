=========================
CORE STRUCTURE – WordMap
=========================

[Main Page]
"Root page with header area, dynamic body, and bottom navigation."

    [Header / Top area]
        "The visual header is now inside each tab (Home / Lessons / Profile), not a global app bar."

    [Body]
        "Body switches between tabs: Home, Lessons, Profile via bottom navigation."

        [Home]
            "Default tab when app opens. Shows current words list with a top row of info."

            [Home top row]
                "A horizontal row with two main elements: counter (left) and chapter title (right)."

                -[Counter]
                    "Top-left. Shows how many words the user has seen/learned (or session counter)."
                        -example: "123 / 7600"
                        -updates when user interacts with words

                -[Chapters title]
                    "Top-right. Shows current chapter/level/category name."
                        -example: "A1.1", "A2.2", "B1 verbs"
                        -tapping it can open a selector (dropdown/sheet) for level/chapter (optional)

            [Words list]
                "Scroll area under the top row. Built from word JSON files in assets/words/."

                -[Word items]
                    "Each word is shown as a card/button with WordMap design."

                    Data fields from word JSON:
                        -Word (de)
                        -Translation Fa
                        -Translation En
                        -Finglish
                        -Photo (optional)
                        -Example sentence (de/en/fa if available)

                    Actions:
                        -tap "open Word page or show details"
                        -play "audio for German word"
                        -bookmark "toggle bookmark state"
                        -word state:
                            -normal (white card)
                            -bookmarked (blue text/shadow or marker)
                            -viewed (light gray background)

                    (Word page)
                        "Detailed view, if needed."
                        =Word (de)
                        =Translations
                        =Example sentence(s)
                        -play "audio"
                        -bookmark
                        -close

        [Lessons]
            "Lessons tab shows lesson categories (cards) and, inside each, lesson cards loaded from JSON."

            [Lessons data source]
                "All lesson content (titles, explanations, examples) comes from JSON in assets/lessons/**.
                 Dart code should not hard-code lesson texts."

                -Folder structure
                    assets/
                      lessons/
                        beginner-basics/
                          alphabet.json
                          reading-rules.json
                          parts-of-speech.json
                          ...
                        grammar/
                          a1-personal-pronouns.json
                          a1-verb-conjugation.json
                          a2-dative-case.json
                          ...
                        lesen-hoeren/
                          der-weg-zur-post.json
                          ...
                        exam-materials/
                          ...

                -Single lesson file
                    "Each JSON file is ONE lesson (e.g. Alphabet, A1 Personal Pronouns)."
                    "Each object inside the JSON array is ONE page/slide of that lesson."

                    Schema for one array element:

                    {
                      "id": "alphabet_1",
                      "subject_en": "German alphabet: overview",
                      "subject_fa": "نمای کلی الفبای آلمانی",
                      "subject_de": "Das Alphabet",
                      "description_en": "Short English explanation for this part...",
                      "description_fa": "توضیح فارسی این بخش...",
                      "examples_en": [
                        "A as in Apfel",
                        "B as in Brot"
                      ],
                      "examples_fa": [
                        "A مثل Apfel",
                        "B مثل Brot"
                      ],
                      "audio_de": "assets/audio/alphabet/alphabet_1.mp3",
                      "images": [
                        "assets/images/alphabet/overview.png"
                      ],
                      "category": "alphabet"
                    }

                    Fields:
                        id              "unique id for this part, e.g. alphabet_1, alphabet_2"
                        subject_en      "short English title of this slide/page"
                        subject_fa      "short Farsi title of this slide/page"
                        subject_de      "short German keyword/title if needed"
                        description_en  "main English explanation text"
                        description_fa  "main Farsi explanation text"
                        examples_en     "array of English example strings or explanations"
                        examples_fa     "array of Farsi example strings"
                        audio_de        "relative audio path or empty string"
                        images          "list of image asset paths or []"
                        category        "lesson category key, e.g. 'alphabet', 'grammar_a1', ..."

            [Lessons list – top level]
                "Top-level screen in Lessons tab: shows lesson categories as cards"

                -[Lesson category cards]
                    "One card per main category."

                    Examples:
                        -Beginner Basics
                        -Grammar
                        -Lesen & Hören
                        -Exam Materials
                        -Useful Dialogues (optional)

                    Card data:
                        -title "e.g. Beginner Basics"
                        -subtitle (optional) "description, e.g. A1–A2 starter lessons"
                        -icon (optional)

                    Behavior:
                        -tap "open Sub Lessons list for this category"

            [Sub Lessons list – inside each category]
                "Inside each category (e.g. Beginner Basics, Grammar) we show another list of cards, one per lesson."

                Data mapping:
                    -For category "Beginner Basics":
                        -Scan assets/lessons/beginner-basics/*.json
                        -For each file:
                            -alphabet.json  → lessonId = "alphabet"
                            -reading-rules.json → lessonId = "reading-rules"
                            -parts-of-speech.json → lessonId = "parts-of-speech"
                        -Each file → ONE lesson card.

                    -For category "Grammar":
                        -Scan assets/lessons/grammar/*.json
                        -Lesson cards may be grouped by level (A1, A2, B1, B2, C1) but UI is still "cards list".
                        -Example lessons:
                            -a1-personal-pronouns.json
                            -a1-verb-conjugation.json
                            ...

                -[Sub lesson card]
                    "Lesson card inside a category."

                    Card fields:
                        -title "human-friendly name, e.g. 'Alphabet', 'Reading rules', 'A1 – Personal Pronouns'"
                        -subtitle (optional) "e.g. 'Beginner Basics', 'A1 Grammar'"
                        -status "Completed / In progress / Not started"
                        -progress "optional page index or percentage"
                        -tick "green tick when completed"

                    Behavior:
                        -tap:
                            -load lesson JSON: assets/lessons/{category}/{lessonId}.json
                            -navigate to Lesson Pages view (slides)

            [Lesson Pages view]
                "Full-screen view that renders each part/slide from lesson JSON as a page."

                Data flow:
                    -Use JsonLessonsRepository.loadLesson(category, lessonId)
                    -Get List<LessonPart> for that lesson

                Rendering for each LessonPart:
                    -title:
                        -if locale == 'fa' and subject_fa not empty → use subject_fa
                        -else use subject_en
                        -show at top of page

                    -description:
                        -if locale == 'fa' and description_fa not empty → use description_fa
                        -else use description_en
                        -render as main body text

                    -examples section (optional):
                        -if there are any examples:
                            -show a small heading:
                                -'Examples' (en)
                                -'مثال‌ها' (fa)
                            -render examples_fa (if locale == fa and not empty) otherwise examples_en

                    -audio (optional):
                        -if audio_de not empty:
                            -show a play button / icon to play German audio

                    -images (optional):
                        -if images list not empty:
                            -render one or more images from given asset paths

                Navigation:
                    -Use PageView or custom pager:
                        -next "go to next LessonPart"
                        -previous (optional)
                    -Bottom actions:
                        -Completed:
                            -on last page, mark lesson as completed in local storage
                            -update lesson card (green tick)
                        -Repeat:
                            -restart lesson from first page

        [Profile]
            "Profile tab is currently used as Settings (no login yet)."

            [Profile / Settings page]
                "No user picture/name. Only general app settings."

                Sections:

                    -Language
                        -label: "Language"
                        -options:
                            -English
                            -Farsi
                        -UI type:
                            -radio group / segmented control / list tiles
                        -on change:
                            -update app locale
                            -persist selection (e.g. SharedPreferences)

                    -Theme
                        -label: "Theme"
                        -options:
                            -System default
                            -Light
                            -Dark
                        -UI type:
                            -radio group / list tiles
                        -on change:
                            -update theme mode
                            -persist selection

                    -Notifications & Reminders
                        -label: "Notifications & Reminders"
                        -toggles:
                            -App notifications (on/off)
                            -Daily reminder (on/off)
                        -behavior:
                            -update in-memory state
                            -save to storage
                            -actual push/notification logic can be implemented separately

    [Bottom Navigation]
        "Persistent bottom bar that switches between main tabs."

        -[Home tab]
            -icon: home
            -label: localized "Home"

        -[Lessons tab]
            -icon: book / layers
            -label: localized "Lessons"

        -[Profile tab]
            -icon: user / settings
            -label: localized "Profile" or "Settings"

=========================
DATA MODELS (IMPLEMENTATION HINT)
=========================

[Word model]
"Existing word JSON model (de, fa, en, etc.) remains as it is in assets/words and current implementation."

[LessonPart model]
"Represents one JSON entry (one slide/page) from assets/lessons/\*\*."

    class LessonPart {
        id: string
        subjectEn: string
        subjectFa: string
        subjectDe: string
        descriptionEn: string
        descriptionFa: string
        examplesEn: List<string>
        examplesFa: List<string>
        audioDe: string
        images: List<string>
        category: string
    }

[Lessons repository]
"Responsible for loading lesson JSON files from assets."

    JsonLessonsRepository
        -loadLesson(category: string, lessonId: string) -> Future<List<LessonPart>>
            "Reads assets/lessons/{category}/{lessonId}.json via rootBundle, parses JSON into LessonPart list."

        -loadAlphabetLesson() (optional helper)
            "Shortcut for Beginner Basics – Alphabet:
             loadLesson('beginner-basics', 'alphabet')"

[Lesson state / progress]
"Lesson completion state is stored locally (e.g. SharedPreferences)."

    -Key: "lesson_completed_{category}_{lessonId}" = true/false
    -When user taps 'Completed' on last page:
        -save true
        -update lesson card tick / status
    -When building Sub Lessons list:
        -read stored completion flags
        -decorate cards with tick/label accordingly

=========================
OPTIONAL / EXTRA FEATURES
=========================

[Onboarding]
=Question "Are you new to German learning?"
-new user
-experienced
-continue

[Search]
-global search over words (and later over lesson titles)
[Search results] -[Word item]
(Word page)

[Bookmarks Page]
[Bookmarks list] -[Word item]
(Word page)

[Settings Page]
"Currently implemented inside Profile tab."
-translation mode "Farsi / English interface"
-theme mode "Light / Dark / System"
-notification / reminder toggles
