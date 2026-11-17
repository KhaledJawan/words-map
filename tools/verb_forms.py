#!/usr/bin/env python3
"""German verb conjugation tables, built from a verb's key forms.

The key forms come from tools/verbs/top-german-verbs.csv (the ~2,900 most frequent
German verbs; source: https://gist.github.com/wanderingstan/7eaaf0e22461b505c749e268c0b72bc4)
or, for verbs missing there, from the "verb" object of a word list (tools/WORDS_PROMPT.md).

Run directly to give every verb of shared/src/commonMain/composeResources/files/words its tables:

    python3 tools/verb_forms.py [--check] [--rebuild]

Verbs that already have forms are left alone; --rebuild builds them again for every verb
whose forms can be found here (verbs that only had key forms from a word list keep theirs).
"""
import csv
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
WORDS_DIR = ROOT / "shared/src/commonMain/composeResources/files/words"
CSV_FILE = Path(__file__).resolve().parent / "verbs/top-german-verbs.csv"

PERSONS = ["ich", "du", "er/sie/es", "wir", "ihr", "sie/Sie"]
REFLEXIVE = {"ich": "mich", "du": "dich", "er/sie/es": "sich", "wir": "uns", "ihr": "euch", "sie/Sie": "sich", "Sie": "sich"}
HABEN = ["habe", "hast", "hat", "haben", "habt", "haben"]
SEIN = ["bin", "bist", "ist", "sind", "seid", "sind"]
HATTE = ["hatte", "hattest", "hatte", "hatten", "hattet", "hatten"]
WAR = ["war", "warst", "war", "waren", "wart", "waren"]
WERDE = ["werde", "wirst", "wird", "werden", "werdet", "werden"]
WUERDE = ["würde", "würdest", "würde", "würden", "würdet", "würden"]
# Verbs whose own Konjunktiv II forms are in everyday use; all others use "würde" + infinitive.
OWN_KONJUNKTIV = {"sein", "haben", "werden", "können", "dürfen", "müssen", "sollen", "wollen", "mögen",
                  "wissen", "kommen", "gehen", "geben", "lassen", "tun", "finden", "bleiben"}
VERB_TAGS = {"verb", "modal_verb", "separable_verb", "reflexive_verb", "irregular_verb"}
# "warten auf", "sich freuen über": the verb is conjugated, the preposition stays as it is.
PREPOSITIONS = {"an", "auf", "aus", "bei", "für", "gegen", "in", "mit", "nach", "über", "um", "unter", "von", "vor", "zu"}
# Prefixes used to find a verb's forms through the verb it is made from ("hochladen" from "laden").
SEPARABLE = ["ab", "an", "auf", "aus", "bei", "ein", "fest", "fort", "her", "herab", "heran", "herauf",
             "heraus", "herein", "herum", "herunter", "hin", "hinaus", "hinein", "hinunter", "hoch",
             "kaputt", "los", "mit", "nach", "um", "vor", "vorbei", "weg", "weiter", "zu", "zurück", "zusammen"]
INSEPARABLE = ["be", "emp", "ent", "er", "miss", "ver", "zer"]

# Key forms, named as in the word list prompt.
KEYS = ["praesens_ich", "praesens_du", "praesens_er", "praeteritum", "partizip2",
        "konjunktiv2", "imperativ_du", "imperativ_ihr", "hilfsverb"]
# Without these no table can be built; the others are optional.
REQUIRED = ["praesens_ich", "praesens_du", "praesens_er", "praeteritum", "partizip2", "hilfsverb"]


def load_csv(path=CSV_FILE):
    """Infinitive -> key forms, for every verb of the CSV."""
    verbs = {}
    with open(path, encoding="utf-8") as handle:
        for row in csv.DictReader(handle):
            verbs[row["Infinitiv"].strip()] = {
                "praesens_ich": row["Präsens_ich"], "praesens_du": row["Präsens_du"],
                "praesens_er": row["Präsens_er, sie, es"], "praeteritum": row["Präteritum_ich"],
                "partizip2": row["Partizip II"], "konjunktiv2": row["Konjunktiv II_ich"],
                "imperativ_du": row["Imperativ Singular"], "imperativ_ihr": row["Imperativ Plural"],
                "hilfsverb": row["Hilfsverb"],
            }
    return verbs


def infinitive_of(german):
    """The bare infinitive of a vocabulary entry: "sich bewerben" -> "bewerben",
    "kommen (aus)" and "warten auf" -> "kommen" and "warten"."""
    text = re.sub(r"\([^)]*\)", "", german).strip()
    reflexive = text.startswith("sich ")
    text = text[5:].strip() if reflexive else text
    words = text.split()
    if len(words) == 2 and words[1] in PREPOSITIONS:
        text = words[0]
    return (text if re.fullmatch(r"[a-zäöüß]+", text) else None), reflexive


def key_forms(infinitive, csv_verbs):
    """Key forms of a verb from the CSV; for a verb missing there, built from the CSV verb it
    is made from ("hochladen" from "laden", "versenden" from "senden"), or by the rule
    for "-ieren" verbs, which are all regular. None when there is no way to tell."""
    if infinitive in csv_verbs:
        return csv_verbs[infinitive]
    for prefix in sorted(SEPARABLE + INSEPARABLE, key=len, reverse=True):
        base = csv_verbs.get(infinitive[len(prefix):]) if infinitive.startswith(prefix) else None
        if not base or " " in base["praesens_ich"] or base["praesens_ich"] in ("—", "-"):
            continue
        if prefix in INSEPARABLE:
            participle = base["partizip2"]
            participle = participle[2:] if participle.startswith("ge") else participle
            return {**{k: (prefix + v if v and v not in ("—", "-") else v) for k, v in base.items()},
                    "partizip2": prefix + participle, "hilfsverb": base["hilfsverb"]}
        separable = {k: (f"{v} {prefix}" if v and v not in ("—", "-") else v) for k, v in base.items()}
        return {**separable, "partizip2": prefix + base["partizip2"], "hilfsverb": base["hilfsverb"]}
    if infinitive.endswith("ieren") and len(infinitive) > 6:
        stem = infinitive[:-2]
        return {"praesens_ich": stem + "e", "praesens_du": stem + "st", "praesens_er": stem + "t",
                "praeteritum": stem + "te", "partizip2": stem + "t", "konjunktiv2": stem + "te",
                "imperativ_du": stem + "e", "imperativ_ihr": stem + "t", "hilfsverb": "haben"}
    return None


def _with_particle(form, particle):
    return f"{form} {particle}" if particle else form


def _ihr(base_inf, er_form):
    stem = base_inf[:-2] if base_inf.endswith("en") else base_inf[:-1]
    if er_form in (stem + "t", stem + "et"):
        return er_form
    return stem + ("et" if stem.endswith(("t", "d")) else "t")


def _past(first, particle):
    """The six Präteritum (or own Konjunktiv II) forms from the ich form."""
    if first.endswith("e"):
        forms = [first, first + "st", first, first + "n", first + "t", first + "n"]
    else:
        du = first + ("est" if first.endswith(("s", "ß", "z", "x", "t", "d")) else "st")
        ihr = first + ("et" if first.endswith(("t", "d")) else "t")
        forms = [first, du, first, first + "en", ihr, first + "en"]
    return [_with_particle(f, particle) for f in forms]


def _reflexive(table, pronoun_index=1):
    """Puts the reflexive pronoun after the word at [pronoun_index] of each form."""
    out = {}
    for person, form in table.items():
        words = form.split(" ")
        words.insert(pronoun_index, REFLEXIVE[person])
        out[person] = " ".join(words)
    return out


def tables(infinitive, parts, reflexive=False):
    """Tense name -> person -> form, from the key forms of a verb."""
    p = {k: (parts.get(k) or "").strip() for k in KEYS}
    # Verbs such as "geschehen" or "regnen" have no ich or du forms.
    impersonal = p["praesens_ich"] in ("—", "-")
    if impersonal:
        p["praesens_ich"] = p["praesens_du"] = p["praesens_er"]
        p["imperativ_du"] = ""
    ich_words = p["praesens_ich"].split()
    particle = ich_words[1] if len(ich_words) == 2 else ""
    base_inf = infinitive[len(particle):] if particle and infinitive.startswith(particle) else infinitive
    first = lambda key: p[key].split()[0] if p[key] else ""

    if base_inf == "sein":
        praesens = SEIN
    else:
        wir = _with_particle(base_inf, particle)
        praesens = [p["praesens_ich"], p["praesens_du"], p["praesens_er"], wir,
                    _with_particle(_ihr(base_inf, first("praesens_er")), particle), wir]
    aux_now, aux_past = (SEIN, WAR) if p["hilfsverb"] == "sein" else (HABEN, HATTE)
    result = {
        "Präsens": praesens,
        "Präteritum": _past(first("praeteritum"), particle),
        "Perfekt": [f"{a} {p['partizip2']}" for a in aux_now],
        "Plusquamperfekt": [f"{a} {p['partizip2']}" for a in aux_past],
        "Futur I": [f"{a} {infinitive}" for a in WERDE],
    }
    if base_inf == "sein":
        result["Konjunktiv II"] = ["wäre", "wärst", "wäre", "wären", "wärt", "wären"]
    elif base_inf in OWN_KONJUNKTIV and p["konjunktiv2"]:
        result["Konjunktiv II"] = _past(first("konjunktiv2"), particle)
    else:
        result["Konjunktiv II"] = [f"{a} {infinitive}" for a in WUERDE]
    tables_ = {name: dict(zip(PERSONS, forms)) for name, forms in result.items()}

    if p["imperativ_du"] and p["imperativ_du"] not in ("—", "-"):
        sie = "seien Sie" if base_inf == "sein" else _with_particle(f"{base_inf} Sie", particle)
        imperativ = {"du": p["imperativ_du"], "ihr": p["imperativ_ihr"], "Sie": sie}
        if reflexive:
            imperativ = {**_reflexive({k: v for k, v in imperativ.items() if k != "Sie"}),
                         "Sie": " ".join(sie.split()[:2] + ["sich"] + sie.split()[2:])}
        tables_["Imperativ"] = {k: v + "!" for k, v in imperativ.items()}
    if reflexive:
        for name in ("Präsens", "Präteritum", "Perfekt", "Plusquamperfekt", "Futur I", "Konjunktiv II"):
            tables_[name] = _reflexive(tables_[name])
    if impersonal:
        tables_ = {name: {k: v for k, v in rows.items() if k in ("er/sie/es", "sie/Sie")} for name, rows in tables_.items()}
    return tables_


def is_verb(word):
    """Whether a vocabulary entry is a verb: tagged as one, or translated as "to …"."""
    return bool(VERB_TAGS & set(word.get("category", []))) or word.get("words", {}).get("en", "").startswith("to ")


def forms_for(word, csv_verbs, parts=None):
    """Conjugation tables for a vocabulary entry, or None when it is not a verb we can conjugate."""
    infinitive, reflexive = infinitive_of(word["words"].get("de", ""))
    if not infinitive or not is_verb(word):
        return None
    source = key_forms(infinitive, csv_verbs) or parts
    if not source or not all(str(source.get(key) or "").strip() for key in REQUIRED):
        return None
    if source.get("hilfsverb") not in ("haben", "sein"):
        return None
    return tables(infinitive, source, reflexive)


def main():
    check_only = "--check" in sys.argv
    rebuild = "--rebuild" in sys.argv
    csv_verbs = load_csv()
    added = 0
    for path in sorted(WORDS_DIR.glob("*.json")):
        words = json.loads(path.read_text(encoding="utf-8"))
        changed = False
        for word in words:
            if word.get("forms") and not rebuild:
                continue
            forms = forms_for(word, csv_verbs)
            if forms and forms != word.get("forms"):
                word["forms"] = forms
                added += 1
                changed = True
        if changed and not check_only:
            path.write_text(json.dumps(words, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print(f"verbs given {'new ' if rebuild else ''}conjugation tables: {added}")


if __name__ == "__main__":
    main()
