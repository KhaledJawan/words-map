#!/usr/bin/env python3
"""Adds a word list (made with the prompt in tools/WORDS_PROMPT.md) to the app.

    python3 tools/add_words.py new_words.json [--check]

For every entry it:
  * checks the level, tags, article and translations, and reports problems
  * never adds a word twice: when the German text is already in the app ("..." and "…"
    count as the same), the existing entry keeps its id and level and gets
      - the new tags (and loses "uncategorized"),
      - the new translations, when their English covers every meaning of the old English,
        otherwise only translations it lacks or never translated (Latin letters in fa/ps),
      - forms, plural, article and example when it had none
  * builds verb tables from tools/verbs/top-german-verbs.csv, or from the entry's
    "verb" key forms when the verb is not in that list
  * gives the word an id and appends it to the file of its level (B1.2 -> b1_2.json)

--check reports everything without writing.
"""
import json
import re
import sys
from pathlib import Path

import verb_forms

ROOT = Path(__file__).resolve().parent.parent
WORDS_DIR = ROOT / "shared/src/commonMain/composeResources/files/words"
STRINGS = ROOT / "shared/src/commonMain/strings/values/strings.xml"
LANGS = ["de", "en", "fa", "ps", "fr", "tr"]
ARTICLES = {"der", "die", "das"}
LEVEL = re.compile(r"^([ABC])([12])\.(\d+)$")


def allowed_tags():
    return set(re.findall(r'name="tag_([a-z0-9_]+)"', STRINGS.read_text(encoding="utf-8")))


def squeeze(text):
    return re.sub(r"\s+", " ", str(text or "")).strip()


def word_text(text):
    """A word or translation, with "..." written as the app writes it: "weder … noch"."""
    return re.sub(r"\s*(?:\.\.\.|…)\s*", " … ", squeeze(text)).strip()


def key(german):
    return word_text(german).lower()


def meanings(text):
    return {part.strip().lower() for part in re.split(r"[/;,]", text or "") if part.strip()}


UNTRANSLATED = re.compile(r"[A-Za-zÄÖÜäöüß]{2,}")


def merge(known, word):
    """Gives a word that is already in the app what a new entry adds; returns what changed."""
    changes = []
    tags = [t for t in known["category"] if t != "uncategorized"]
    new_tags = [t for t in word["category"] if t not in tags and t != "uncategorized"]
    if new_tags:
        known["category"] = tags + new_tags
        changes.append("tags +" + ", ".join(new_tags))
    old, new = known["words"], word["words"]
    if meanings(new.get("en")) >= meanings(old.get("en")):
        langs = [lang for lang in LANGS[1:] if new.get(lang) and new[lang] != old.get(lang)]
    else:
        langs = [lang for lang in LANGS[1:] if new.get(lang) and (
            not old.get(lang) or lang in ("fa", "ps") and UNTRANSLATED.search(old[lang]))]
    for lang in langs:
        old[lang] = new[lang]
    if langs:
        changes.append("translations " + ", ".join(langs))
    for name in ("forms", "plural", "article", "examples"):
        if name in word and name not in known:
            known[name] = word[name]
            changes.append(name)
    return changes


def level_file(level):
    band, major, minor = LEVEL.match(level).groups()
    return f"{band.lower()}{major}_{minor}.json", f"w{band}{major}-{minor}-"


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if not args:
        sys.exit(__doc__)
    check_only = "--check" in sys.argv
    raw = Path(args[0]).read_text(encoding="utf-8").strip()
    raw = re.sub(r"^```(?:json)?\s*|\s*```$", "", raw)  # tolerate a pasted code block
    entries = json.loads(raw)
    tags = allowed_tags()
    csv_verbs = verb_forms.load_csv()

    files = {p.name: json.loads(p.read_text(encoding="utf-8")) for p in sorted(WORDS_DIR.glob("*.json"))}
    existing = {}
    for words in files.values():
        for word in words:
            existing.setdefault(key(word["words"]["de"]), word)

    added, merged, invalid, problems = {}, [], 0, []
    for number, entry in enumerate(entries, 1):
        texts = {lang: word_text((entry.get("words") or {}).get(lang)) for lang in LANGS}
        german = texts["de"]
        label = f"#{number} {german or '(no German text)'}"
        level = squeeze(entry.get("level"))
        if not german or not LEVEL.match(level):
            problems.append(f"{label}: skipped, needs words.de and a level like A2.1")
            invalid += 1
            continue
        article = squeeze(entry.get("article")).lower() or None
        if article and article not in ARTICLES:
            problems.append(f"{label}: article '{article}' is not der/die/das, left out")
            article = None
        if article and german.lower().startswith(article + " "):
            german = texts["de"] = german[len(article) + 1:]
        missing = [lang for lang in LANGS[1:] if not texts[lang]]
        if missing:
            problems.append(f"{label}: no translation for {', '.join(missing)}")
        category = [t for t in entry.get("category") or [] if t in tags]
        unknown = [t for t in entry.get("category") or [] if t not in tags]
        if unknown:
            problems.append(f"{label}: unknown tags {unknown} left out")
        known = existing.get(key(german))
        is_a1 = known["id"].startswith("wA1") if known else level.startswith("A1")
        if "a1_core" in category and not is_a1:
            category.remove("a1_core")
            problems.append(f"{label}: a1_core left out, the word is not A1")
        word = {"category": category or ["uncategorized"]}
        if article:
            word["article"] = article
        if squeeze(entry.get("plural")):
            word["plural"] = squeeze(entry["plural"])
        word["words"] = {lang: text for lang, text in texts.items() if text}
        example = squeeze((entry.get("examples") or {}).get("de"))
        if example:
            word["examples"] = {"de": example}
        forms = verb_forms.forms_for(word, csv_verbs, entry.get("verb"))
        if forms:
            word["forms"] = forms
        elif verb_forms.is_verb(word) and " " not in german:
            problems.append(f"{label}: looks like a verb, but has no forms (not in the verb list, and its \"verb\" key forms are missing or incomplete)")

        if known:
            changes = merge(known, word)
            merged.append(f"= {known['words']['de']} ({known['id']}): {'; '.join(changes) or 'nothing new'}")
            continue
        name, prefix = level_file(level)
        words = files.setdefault(name, [])
        numbers = [int(w["id"][len(prefix):]) for w in words if w["id"].startswith(prefix) and w["id"][len(prefix):].isdigit()]
        word = {"id": f"{prefix}{max(numbers, default=0) + 1:04d}", **word}
        words.append(word)
        existing[key(german)] = word
        added[level] = added.get(level, 0) + 1

    if not check_only:
        for name, words in files.items():
            (WORDS_DIR / name).write_text(json.dumps(words, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    for line in problems:
        print("!", line)
    for line in merged:
        print(line)
    print(f"added: {sum(added.values())} {dict(sorted(added.items()))}")
    print(f"already in the app, merged: {len(merged)}")
    if invalid:
        print(f"skipped as invalid: {invalid}")
    if check_only:
        print("nothing written (--check)")


if __name__ == "__main__":
    main()
