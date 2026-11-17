# reading: the reading texts

The app builds its Reading section from this folder, the same way as `gramatik`:
one folder per level, one `.json` file per text. Add a file, rebuild, and the text
is in the app.

```
reading/
  _example/
    ein-neuer-nachbar.json   a complete example text, not shown in the app
  a1/
    der-kater-carlo.json
  a2/
  b1/
  b2/
  c1/
```

To add a text, copy `_example/ein-neuer-nachbar.json` into a level folder, rename it
and replace its contents. Folders whose names start with `_` are not part of the app
(they are not even packed into the APK), so `_example` is only there to copy from.

## A text file

```json
{
  "order": 2,
  "title": "Der Ausflug",
  "description": { "en": "One sentence for the card.", "fa": "…", "de": "…" },
  "keywords": ["Ausflug", "Zug"],
  "text": "First paragraph of the story.\n\nSecond paragraph.",
  "questions": [
    { "question": "Wohin fährt die Klasse?", "answers": ["Nach Bonn", "Nach Köln", "Nach Trier", "Nach Mainz"] }
  ]
}
```

| Field | What it is |
| --- | --- |
| `title` | Title of the text. A plain string is used in every language. |
| `description` | Short line on the card and under the title. |
| `text` | The text to read. Leave an empty line (`\n\n`) between paragraphs; `**two stars**` make a word bold. |
| `questions` | The questions at the end, usually 5 or 6. All must be answered right to pass. |
| `order` | Position inside the level, lowest first. Optional. |
| `keywords` | Extra words the search should find the text by. Optional. |
| `source` | Where the text comes from, for texts taken from elsewhere. Not shown in the app. Optional. |

## Tapping words

Every word of the text that is in the app's vocabulary (`files/words/`) can be tapped
and opens the same word card as the Home screen. Nothing has to be marked in the text:
the app finds the words itself, including phrases such as "rund um die Uhr" and simple
forms such as "wohnt" for "wohnen". Verbs are also found in every form of their tense
tables ("war", "ist gekommen", "fange an"). Words that are not in the vocabulary stay
plain. Adding words to the vocabulary (see `tools/WORDS_PROMPT.md`) makes more words
tappable in every text.

## Questions

- **Write the right answer first.** The app shuffles the answers every time, so the
  learner never sees it first. The questions themselves stay in the order you wrote them.
- A question needs at least two answers; four works best.
- When every question is answered correctly, the text is marked done and gets a check
  mark. After a mistake the learner can try again, with the answers in a new order.
- A text without questions shows a "Mark as completed" button instead.

`question` and each answer can be a plain string, or translations like
`{ "de": "…", "en": "…", "fa": "…" }` when the learner should read them in their own
language. Missing languages fall back to English, then German.
