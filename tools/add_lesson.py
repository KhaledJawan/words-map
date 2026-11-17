#!/usr/bin/env python3
"""Puts grammar lesson texts (written with tools/GRAMMAR_PROMPT.md) into the app.

    python3 tools/add_lesson.py 27 lesson.md --book a1-b1 [--lang fa] [--check]   one lesson: lesson 27
    python3 tools/add_lesson.py lessons.md --book b2-c1 [--lang fa] [--check]     several lessons, each
                                                                                after a line "=== LESSON 27 ==="

It finds each lesson in shared/src/commonMain/composeResources/files/gramatik by its number, checks the text, and
saves it next to the lesson as <lesson>.<lang>.md (Farsi unless --lang says otherwise).
The two books number their lessons from 1 each, so --book says which one: a1-b1 (folders
a1, a2, b1) or b2-c1 (folders b2, c1). --check only reports.
"""
import json
import re
import sys
from pathlib import Path

GRAMMAR = Path(__file__).resolve().parent.parent / "shared/src/commonMain/composeResources/files/gramatik"
MARKER = re.compile(r"^\s*=+\s*(?:LESSON|LEKTION|درس)\s*([0-9۰-۹]+)\s*=+\s*$", re.I | re.M)
KINDS = {"NOTE", "TIP", "IMPORTANT", "WARNING", "RULE", "EXAMPLE", "SUMMARY"}
BOOKS = {"a1-b1": ("a1", "a2", "b1"), "b2-c1": ("b2", "c1")}
QUIZ_NAMES = {"quiz", "questions", "fragen", "übung", "test", "تمرین", "آزمون", "پوښتنې", "ازموینه"}


def find_lesson(number, book):
    folders = BOOKS[book] if book else None
    found = [
        path for path in sorted(GRAMMAR.glob("[!_]*/*.json"))
        if (folders is None or path.parent.name in folders)
        and json.loads(path.read_text(encoding="utf-8")).get("number") == number
    ]
    if not found:
        sys.exit(f"There is no lesson {number}" + (f" in the {book} book." if book else f" in {GRAMMAR}."))
    if len(found) > 1:
        names = ", ".join(f"{p.parent.name}/{p.name}" for p in found)
        sys.exit(f"Lesson {number} is in more than one book ({names}); add --book {' or --book '.join(BOOKS)}.")
    return found[0]


def clean(text):
    text = text.replace("\r\n", "\n").strip()
    # Answers pasted from a chat often come wrapped in a ```markdown block.
    text = re.sub(r"^```[a-zA-Z]*\n", "", text)
    text = re.sub(r"\n```$", "", text)
    return text.strip() + "\n"


def check(text):
    problems, quiz, questions = [], False, []
    for number, line in enumerate(text.splitlines(), 1):
        stripped = line.strip()
        heading = re.match(r"^#{2,6}\s+(.+?)\s*$", stripped)
        if heading:
            # "### 3. question" inside the quiz is a question, not the end of the quiz.
            if quiz and re.match(r"^[0-9۰-۹]+[.)]", heading.group(1)):
                questions.append([heading.group(1), [], 0])
                continue
            quiz = heading.group(1).rstrip(":").lower() in QUIZ_NAMES
            continue
        marker = re.match(r"^>\s*\[!([A-Za-z]+)]", stripped)
        if marker and marker.group(1).upper() not in KINDS:
            problems.append(f"line {number}: unknown card [!{marker.group(1)}], shown as a note (use {', '.join(sorted(KINDS))})")
        if quiz:
            option = re.match(r"^[-*+]\s*\[([ xX])]\s*(.+)|^([-*+])\s+(.+)", stripped)
            if re.match(r"^([0-9۰-۹]+)[.)]\s+|^[?؟]", stripped):
                questions.append([stripped, [], 0])
            elif option and questions:
                questions[-1][1].append((option.group(2) or option.group(4)).strip())
                questions[-1][2] += option.group(1) in ("x", "X") or option.group(3) == "*"
    for question, answers, right in questions:
        if len(answers) < 2 or right != 1:
            problems.append(f"question \"{question[:50]}\": {len(answers)} answers, {right} marked right; it needs 2+ answers and exactly one right answer ([x] or *), or it is left out")
        doubled = sorted({a for a in answers if answers.count(a) > 1})
        if doubled:
            problems.append(f"question \"{question[:50]}\": the answer {', '.join(doubled)} is there twice")
    if not questions:
        problems.append("no questions: add a \"## Quiz\" section, or the lesson gets a \"Mark as completed\" button instead")
    good = sum(1 for _, answers, right in questions if len(answers) >= 2 and right == 1)
    cards = len(re.findall(r"^>\s*\[!", text, re.M))
    tables = len(re.findall(r"^\|\s*:?-{2,}", text, re.M))
    return problems, f"{good} questions, {cards} cards, {tables} tables"


def split_lessons(text):
    """(number, text) for each part of a file with "=== LESSON 27 ===" lines."""
    marks = list(MARKER.finditer(text))
    if not marks:
        sys.exit('No "=== LESSON <number> ===" lines found. For one lesson, give its number: add_lesson.py 27 lesson.md')
    digits = str.maketrans("۰۱۲۳۴۵۶۷۸۹", "0123456789")
    return [
        (int(mark.group(1).translate(digits)), text[mark.end():marks[i + 1].start() if i + 1 < len(marks) else len(text)])
        for i, mark in enumerate(marks)
    ]


def save(number, text, lang, book, check_only):
    lesson = find_lesson(number, book)
    text = clean(text)
    problems, summary = check(text)
    for problem in problems:
        print(f"! lesson {number}: {problem}")
    print(f"lesson {number}: {lesson.parent.name}/{lesson.name} – {summary}")
    if not check_only:
        target = lesson.with_name(f"{lesson.stem}.{lang}.md")
        existed = target.exists()
        target.write_text(text, encoding="utf-8")
        print(("  replaced " if existed else "  written ") + f"{lesson.parent.name}/{target.name}")


def option(name, default=None):
    """The value after --name, removed from sys.argv."""
    if name not in sys.argv:
        return default
    index = sys.argv.index(name)
    if index + 1 >= len(sys.argv):
        sys.exit(f"{name} needs a value.")
    value = sys.argv[index + 1]
    del sys.argv[index:index + 2]
    return value


def main():
    lang = option("--lang", "fa")
    book = option("--book")
    if book is not None and book not in BOOKS:
        sys.exit(f"--book is {' or '.join(BOOKS)}, not {book}.")
    check_only = "--check" in sys.argv
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if len(args) == 2 and args[0].isdigit():
        parts = [(int(args[0]), Path(args[1]).read_text(encoding="utf-8"))]
    elif len(args) == 1:
        parts = split_lessons(Path(args[0]).read_text(encoding="utf-8"))
    else:
        sys.exit(__doc__)
    for number, text in parts:
        save(number, text, lang, book, check_only)
    if check_only:
        print("nothing written (--check)")


if __name__ == "__main__":
    main()
