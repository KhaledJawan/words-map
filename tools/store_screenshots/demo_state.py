"""The app data the store screenshots are taken with, for both platforms.

    python3 demo_state.py android en > wordsmap.xml   # SharedPreferences file
    python3 demo_state.py ios fa <simulator id>       # writes it into the booted simulator

A few bookmarks, progress in chapter A1.1 (some words learned, 4 of today's 10 known, a
6-day streak), a daily reminder at 19:00 and two categories of the learner's own words.
Light theme, English meanings.
Add `highlight` to switch on the highlights of the reading texts.
"""
import datetime
import json
import os
import subprocess
import sys
from xml.sax.saxutils import escape, quoteattr

HERE = os.path.dirname(os.path.abspath(__file__))
WORDS = os.path.join(HERE, "../../shared/src/commonMain/composeResources/files/words/a1_1.json")

LEARNED_BEFORE = 68  # A1.1 words learned on earlier days
PER_DAY = 10
KNOWN_TODAY = 4
STREAK = 6

OWN_LISTS = [
    {"id": "list-work", "name": "Work"},
    {"id": "list-berlin", "name": "Holiday in Berlin"},
]
OWN_WORDS = [
    ("Termin", "appointment", "der", "Termine", "Ich habe morgen einen Termin.", "list-work"),
    ("Besprechung", "meeting", "die", "Besprechungen", "Die Besprechung beginnt um neun.", "list-work"),
    ("Kollege", "colleague", "der", "Kollegen", None, "list-work"),
    ("Bewerbung", "job application", "die", "Bewerbungen", "Ich schreibe eine Bewerbung.", "list-work"),
    ("Feierabend", "end of the working day", "der", None, "Endlich Feierabend!", "list-work"),
    ("Sehenswürdigkeit", "sight, attraction", "die", "Sehenswürdigkeiten", None, "list-berlin"),
    ("Hauptbahnhof", "main station", "der", "Hauptbahnhöfe", None, "list-berlin"),
    ("Fahrkarte", "ticket", "die", "Fahrkarten", "Wo kann ich eine Fahrkarte kaufen?", "list-berlin"),
    ("übernachten", "to stay overnight", None, None, "Wir übernachten im Hotel.", "list-berlin"),
]


def state(language, highlight):
    with open(WORDS, encoding="utf-8") as f:
        chapter = [w["id"] for w in json.load(f)]
    with open(os.path.join(HERE, "bookmark_ids.txt")) as f:
        history = f.read().strip().split(",")

    today = (datetime.date.today() - datetime.date(1970, 1, 1)).days
    learned_before = chapter[:LEARNED_BEFORE]
    today_ids = chapter[LEARNED_BEFORE:LEARNED_BEFORE + PER_DAY]
    known = today_ids[:KNOWN_TODAY]

    words = []
    for i, (text, translation, article, plural, example, list_id) in enumerate(OWN_WORDS):
        word = {"id": f"mine-demo{i + 1:02d}", "text": text, "translation": translation}
        if article:
            word["article"] = article
        if plural:
            word["plural"] = plural
        if example:
            word["example"] = example
        word["list"] = list_id
        words.append(word)

    return {
        "app_language": language,
        "theme_mode": "LIGHT",
        "last_level": "A1.1",
        "app_notifications": True,
        "daily_reminder": True,
        "reminder_minute_of_day": "1140",  # 19:00
        "highlight_reading_words": highlight,
        # The first 8 are bookmarked; the last 2 were bookmarked once and taken away.
        "bookmarked_word_ids": history[:8],
        "bookmark_history": ",".join(history),
        "user_word_lists": json.dumps(OWN_LISTS, ensure_ascii=False, separators=(",", ":")),
        "user_words": json.dumps(words, ensure_ascii=False, separators=(",", ":")),
        "learn_source": "level:A1.1",
        "learn_words_per_day": str(PER_DAY),
        "learn_day": str(today),
        "learn_today_ids": ",".join(today_ids),
        "learn_known_today": known,
        "learned_word_ids": learned_before + known,
        "learn_done_days": [str(today - d) for d in range(1, STREAK + 1)],
    }


def android(values):
    lines = ["<?xml version='1.0' encoding='utf-8' standalone='yes' ?>", "<map>"]
    for key, value in values.items():
        if isinstance(value, bool):
            lines.append(f'    <boolean name={quoteattr(key)} value="{str(value).lower()}" />')
        elif isinstance(value, list):
            lines.append(f"    <set name={quoteattr(key)}>")
            lines += [f"        <string>{escape(item)}</string>" for item in value]
            lines.append("    </set>")
        else:
            lines.append(f"    <string name={quoteattr(key)}>{escape(value)}</string>")
    lines.append("</map>")
    return "\n".join(lines) + "\n"


def ios(values, device):
    """
    Writes the values one by one into the app's own preferences file, by its path. On the
    iOS 18 simulator, `defaults` with the bundle id writes another file than the app reads.
    """
    tool = ["xcrun", "simctl", "spawn", device, "defaults"]
    container = subprocess.run(
        ["xcrun", "simctl", "get_app_container", device, "dev.nefrin.wordsmap", "data"],
        check=True, capture_output=True, text=True,
    ).stdout.strip()
    domain = f"{container}/Library/Preferences/dev.nefrin.wordsmap"
    for old in ("dev.nefrin.wordsmap", domain):
        subprocess.run(tool + ["delete", old], stderr=subprocess.DEVNULL)
    for key, value in values.items():
        if isinstance(value, bool):
            typed = ["-bool", "true" if value else "false"]
        elif isinstance(value, list):
            typed = ["-array", *value]
        else:
            typed = ["-string", value]
        subprocess.run(tool + ["write", domain, key, *typed], check=True)

if __name__ == "__main__":
    platform, language = sys.argv[1], sys.argv[2]
    values = state(language, highlight="highlight" in sys.argv[3:])
    if platform == "android":
        sys.stdout.write(android(values))
    else:
        ios(values, sys.argv[3])
