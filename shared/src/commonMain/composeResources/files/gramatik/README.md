# gramatik: the grammar lessons

The app builds its Grammar section from this folder. Nothing has to be registered
in code: add a file, rebuild, and the lesson is in the app. The `reading` folder next to
this one works the same way for the reading texts.

```
gramatik/
  _example/                a complete example lesson, not shown in the app
    adverbien.json
    adverbien.webp
  a1/                      one folder per chapter (level)
    modalverben.json       one file per lesson
    modalverben.jpg        its cover photo
  a2/
  b1/
  b2/
  c1/
```

The text of a lesson can also be a Markdown file next to it, one per language, such as
`a1/01-ich-du-er-sie-es-wir.fa.md`, with headings, tables, lists, colored cards (notes,
rules, examples …) and the quiz. That format, a prompt for writing it, and
`tools/add_lesson.py`, which puts a text in the right place, are described in
`tools/GRAMMAR_PROMPT.md`. When a lesson has such a file, it is shown instead of
`full_description` and `examples`, and its quiz replaces `questions`.

Folders whose names start with `_` are not part of the app (they are not even packed
into the APK), so `_example` is only there to copy from. To see the example in the
app, copy both of its files into `a1/`.

The chapters A1, A2, B1, B2 and C1 always appear, in that order. Any other folder
you add (for example `c2`) appears after them.

## Adding a lesson

1. Copy `_example/adverbien.json` into the chapter folder and rename it. Use lower
   case letters, digits and dashes, for example `modalverben.json`.
2. Put the cover photo next to it and write its file name in `cover`.
3. Fill in the texts.

```json
{
  "number": 5,
  "topic": "Modalverben",
  "cover": "modalverben.jpg",
  "keywords": ["können", "müssen", "dürfen"],
  "title":            { "de": "Modalverben", "en": "Modal verbs", "fa": "…" },
  "description":      { "en": "One or two sentences for the lesson card.", "fa": "…" },
  "full_description": { "en": "First paragraph.\n\nSecond paragraph.", "fa": "…" },
  "examples": [
    { "de": "Ich **kann** schwimmen.", "en": "I **can** swim.", "fa": "…" }
  ],
  "questions": [
    { "question": "Ich ___ heute nicht kommen.", "answers": ["kann", "kannst", "können", "könnt"] },
    {
      "question": { "de": "Welches Verb ist ein Modalverb?", "en": "Which verb is a modal verb?", "fa": "…" },
      "answers": ["müssen", "gehen", "haben", "lernen"]
    }
  ]
}
```

| Field | What it is |
| --- | --- |
| `number` | Number of the lesson in the book. Shown in front of it, and the lessons of a chapter are listed in this order. |
| `topic` | What the lesson teaches, such as `"Personalpronomen"`. The cards show it as the main line, with `title` below it; the lesson page shows it under the title. |
| `title` | Title of the lesson, for example the sentence the book uses (`"Ich, du, er, sie, es, wir, ihr, sie und Sie"`). |
| `description` | Short text on the lesson card and under the title. |
| `cover` | File name of the cover photo in the same folder (`.jpg`, `.png` or `.webp`). A wide photo works best; it is cropped to 16:9. Without it the lesson shows a plain placeholder. |
| `full_description` | The explanation. Leave an empty line (`\n\n`) between paragraphs. |
| `examples` | Example sentences. `de` is the German sentence, the other keys are its translations. |
| `order` | Position inside the chapter, lowest first, when it should differ from `number`. Lessons with neither come last, sorted by file name. |
| `keywords` | Extra words the search should find this lesson by. Optional. |
| `questions` | The questions at the end of the lesson, usually 5. See below. |

Put `**two stars**` around a word to highlight it, in explanations and in examples.

## Questions

- **Write the right answer first.** The app shuffles the answers every time, so the
  learner never sees it first. The questions themselves stay in the order you wrote them.
- A question needs at least two answers; four works best.
- When every question is answered correctly, the lesson is marked learned and gets a
  check mark in its chapter. After a mistake the learner can try again, with the answers
  in a new order.
- A lesson without questions shows a "Mark as completed" button instead.

`question` and each answer can be a plain string (shown as written to everyone) or
translations like `{ "de": "…", "en": "…", "fa": "…" }`.

## Translating

Every text is a set of translations keyed by language code:
`de`, `en`, `fa`, `ps`, `fr`, `tr`. To translate a lesson, add the missing code
next to the others. No other change is needed.

The app shows a lesson in the learner's "Translate To" language. When that
language is missing, Pashto falls back to Farsi, then everything falls back to
English, then to German. A lesson with only an English text is therefore still
shown to everyone.

## Good to know

- The search looks at `title` and `keywords` in every language, so the German name of
  a topic always finds it, and at `description` in the language the learner reads.
- A file with a JSON mistake is skipped, and the rest of the chapter still loads.
  If a new lesson does not show up, check its commas and quotes first.
