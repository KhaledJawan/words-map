#!/usr/bin/env python3
"""Imports the vocabulary of the old Flutter app into shared/src/commonMain/composeResources/files/words.

Usage: python3 tools/import_words.py <old words dir> [--check] [--overwrite]

This was a one-time import. It rewrites every level file from the old app, so words
added later with add_words.py and verb tables from verb_forms.py would be lost; it
refuses to run over existing files unless --overwrite is given.

What it changes on the way in:
  * drops `audios` and `image` (the new app has no audio, images were never used)
  * drops the per-word `level`; the file name is the level (a1_1.json -> A1.1)
  * collapses whitespace and removes invisible direction marks
  * repairs brackets that were reversed by the PDF import:  ")Pl.("  ->  "(Pl.)"
  * repairs Farsi text whose parts were reversed or split by the PDF import
  * moves German notes ("Bsp.: ...", "Pl.: ...") out of the Farsi translation;
    complete "Bsp." sentences become the word's German example
  * corrects Farsi words of the B2 levels whose letters the PDF import swapped
    (tools/farsi_spelling_b2.json, wrong word -> right word)
  * removes words in a later level that repeat a word from an earlier level
  * applies the corrections in tools/word_fixes.json (id -> {lang: text})
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "shared/src/commonMain/composeResources/files/words"
FIXES_FILE = Path(__file__).resolve().parent / "word_fixes.json"
SPELLING_FILE = Path(__file__).resolve().parent / "farsi_spelling_b2.json"
# Levels that came from a PDF. Only they need the Farsi spelling corrections: some of the
# wrong spellings are real words elsewhere ("شام" is dinner, here it stands for "شما").
PDF_LEVELS = {"B2.1", "B2.2"}
LANGS = ["de", "en", "fa", "ps", "fr", "tr"]
ZWNJ = "‌"

INVISIBLE = re.compile("[​‎‏‪-‮⁦-⁩﻿­]")
# German study notes that the PDF import glued to the end of the Farsi text.
NOTE = re.compile(r"\s*(Bsp\.?:|Def\.?:|Pl\.?:|Sg\.?:|K\.:|V\.:|Adj\.:|Komp\.:|nicht trennb\.|[=≠]\s*[A-Za-zÄÖÜäöü])")
GRAMMAR_TAG = re.compile(r"\s*\((?:Nom|Akk|Dat|Gen|Pl|Sg)\.\)")
FA_WORD = re.compile("[\u0621-\u063a\u0641-\u064a\u067e\u0686\u0698\u06a9\u06af\u06cc]+")
FA_SUFFIX = re.compile(r"^(ها|های|هایی|ای)(?=[\s،/]|$)")
FA_SUFFIX_AFTER_GAP = re.compile(r"(\S)\s{2,}(?=(?:ها|های|هایی|ای)(?:[\s،/]|$))")


def squeeze(text):
    return re.sub(r"\s+", " ", INVISIBLE.sub("", text)).strip()


def fix_brackets(text):
    """Turns ")Pl.(" back into "(Pl.)" and closes or drops brackets left without a partner."""
    out, depth, i = [], 0, 0
    while i < len(text):
        char = text[i]
        if char == ")" and depth == 0:
            opening, closing = text.find("(", i + 1), text.find(")", i + 1)
            if opening != -1 and (closing == -1 or opening < closing) and opening - i <= 25:
                out.append("(" + text[i + 1:opening] + ")")
                i = opening + 1
                continue
        depth += char == "("
        depth -= char == ")" and depth > 0
        out.append(char)
        i += 1
    text = "".join(out)
    while text.count("(") != text.count(")"):
        dangling = re.search(r"\s[()]$", text)
        if dangling:
            text = text[: dangling.start()]
        elif text.count("(") > text.count(")"):
            text = text + ")"
        else:
            text = "(" + text
    return text.strip()


def fix_farsi_order(text):
    """Undo the PDF import's handling of the zero-width joiner in Farsi.

    A word like "فرصت‌های شغلی" arrived either as "های شغلی  فرصت" (parts
    reversed) or as "فرصت  های شغلی" (joiner turned into two spaces).
    """
    parts = [p for p in re.split(r"\s{2,}", text.strip()) if p]
    if len(parts) > 1 and FA_SUFFIX.search(parts[0]):
        return ZWNJ.join(reversed(parts))
    if len(parts) == 1 and FA_SUFFIX.search(parts[0]):
        suffix, _, rest = parts[0].partition(" ")
        return f"{rest}{ZWNJ}{suffix}" if rest else parts[0]
    return FA_SUFFIX_AFTER_GAP.sub(lambda m: m.group(1) + ZWNJ, text)


def split_note(text):
    match = NOTE.search(text)
    if not match or not re.search("[؀-ۿ]", text[: match.start()]):
        return text, None
    return text[: match.start()], text[match.start():].strip()


def example_from_note(note):
    if not note or not re.match(r"Bsp\.?:", note):
        return None
    sentence = squeeze(GRAMMAR_TAG.sub("", fix_brackets(re.sub(r"^Bsp\.?:\s*", "", note))))
    complete = re.search(r"[.!?]$", sentence) and sentence.count("„") == sentence.count("“")
    return sentence if complete else None


def level_of(file_name):
    match = re.match(r"^([a-z])(\d)_(\d+)\.json$", file_name)
    return f"{match.group(1).upper()}{match.group(2)}.{match.group(3)}"


def clean_word(raw, report, spelling):
    texts, example = {}, None
    for lang in LANGS:
        text = str((raw.get("words") or {}).get(lang) or "")
        if lang == "fa":
            text, note = split_note(text)
            if note:
                report["notes_removed"] += 1
                example = example_from_note(note)
            text = fix_farsi_order(text)
            text = FA_WORD.sub(lambda m: spelling.get(m.group(), m.group()), text)
        text = squeeze(fix_brackets(squeeze(text)))
        if text:
            texts[lang] = text

    examples = {k: squeeze(str(v)) for k, v in (raw.get("examples") or {}).items() if squeeze(str(v))}
    if example and "de" not in examples:
        examples["de"] = example
        report["examples_recovered"] += 1

    word = {"id": raw["id"], "category": list(raw.get("category") or [])}
    for key in ("article", "plural"):
        if squeeze(str(raw.get(key) or "")):
            word[key] = squeeze(str(raw[key]))
    word["words"] = texts
    if examples:
        word["examples"] = examples
    return word


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    check_only = "--check" in sys.argv
    if not args:
        sys.exit(__doc__)
    source = Path(args[0])
    if not check_only and any(OUT_DIR.glob("*.json")) and "--overwrite" not in sys.argv:
        sys.exit(f"{OUT_DIR} already has words. Re-importing would replace them; pass --overwrite to do it anyway.")
    fixes = json.loads(FIXES_FILE.read_text(encoding="utf-8")) if FIXES_FILE.exists() else {}
    spelling = json.loads(SPELLING_FILE.read_text(encoding="utf-8"))
    report = {"notes_removed": 0, "examples_recovered": 0, "level_fixed": 0, "duplicates": [], "changed": 0}
    seen, total, used_fixes = {}, 0, set()

    for path in sorted(source.glob("*.json")):
        level = level_of(path.name)
        words = []
        for raw in json.loads(path.read_text(encoding="utf-8")):
            if raw.get("level") != level:
                report["level_fixed"] += 1
            word = clean_word(raw, report, spelling if level in PDF_LEVELS else {})
            for lang, text in (fixes.get(word["id"]) or {}).items():
                word["words"][lang] = text
                used_fixes.add(word["id"])
            before = {l: squeeze(str(raw["words"].get(l) or "")) for l in LANGS}
            if any(before[l] != word["words"].get(l, "") for l in LANGS):
                report["changed"] += 1
            key = word["words"].get("de", "").lower()
            if key in seen:
                report["duplicates"].append((word["id"], word["words"]["de"], seen[key]))
                continue
            seen[key] = word["id"]
            words.append(word)
        total += len(words)
        if not check_only:
            OUT_DIR.mkdir(parents=True, exist_ok=True)
            (OUT_DIR / path.name).write_text(
                json.dumps(words, ensure_ascii=False, indent=1) + "\n", encoding="utf-8"
            )
        print(f"{path.name}: {len(words)} words ({level})")

    print(f"total: {total} words")
    print(f"level corrected: {report['level_fixed']}, texts repaired: {report['changed']}, "
          f"notes removed: {report['notes_removed']}, examples recovered: {report['examples_recovered']}, "
          f"duplicates dropped: {len(report['duplicates'])}, manual fixes applied: {len(used_fixes)}")
    unused = sorted(set(fixes) - used_fixes)
    if unused:
        print("fixes for unknown ids:", unused)


if __name__ == "__main__":
    main()
