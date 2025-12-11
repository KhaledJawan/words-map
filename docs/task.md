LESSONS-01 – Implement Lessons tab with categories, sub-lessons, and slide-based detail view
Goal

Implement the Lessons tab in the WordMap app with:

A clear category structure (Beginner, Grammar, etc.)

Sub-lessons (subcategories) under each main category

A slide-based detail page for each sub-lesson

Completion tracking with a green tick on completed lessons

The implementation should be easily extendable so that new categories, sub-lessons, and slides can be added later by simply updating a data structure, without duplicating UI code.

Categories and initial structure

Implement the following main categories in the Lessons tab (vertical list of cards):

Beginner Basics

Grammar

Useful Dialogues

Reading & Listening

Exam Practice

For now, only Beginner Basics will have real sub-lessons. The others can exist with placeholder sub-lessons or empty state to be filled later.

Beginner Basics – initial sub-lessons

Under Beginner Basics, create the following sub-lessons (subcategories):

Alphabet

Reading rules

Parts of speech

Hallo

All about German

Each sub-lesson must:

Be rendered as a card or tile inside the category (e.g. a vertical list of cards).

Show:

Title (e.g. "Reading rules")

A tick icon to indicate completion state:

Green check icon if completed

Grey/disabled check icon if not completed yet

The tick state must be persistent between app launches.

Data model

Create a simple data model to keep the structure flexible:

LessonCategory

id (string)

title (string)

description (optional, string)

lessons (list of LessonItem)

LessonItem (sub-lesson)

id (string)

title (string)

categoryId (string or implied)

slides (list of LessonSlide)

isCompleted (bool) – this should be loaded from persistent storage, not hard-coded

LessonSlide

id (string)

text (string) – the main slide content

optional: title (string)

For now, use placeholder slide text (e.g. “TODO: Add real content for Reading rules slide 1”) but make sure the structure is ready for real content later.

All category and lesson definitions for this feature can be defined as an in-memory list (e.g. a static list or a small repository/service class). The focus is on structure and UI, not the final content text.

Persistence of completion state

Implement simple persistent tracking of sub-lesson completion:

Use a local persistence mechanism (e.g. SharedPreferences in Flutter).

Store completion per LessonItem.id.

Example key: lesson*completed*<lessonId> → true/false.

On app startup (or when the Lessons tab is built), load the completion states and update the UI.

When a user presses Completed at the end of a lesson, set the completion flag for that lesson to true and update the UI (green tick).

Lessons tab UI

In the Lessons tab:

Display a scrollable list of LessonCategory cards.

Each category card shows:

Category title (e.g. "Beginner Basics")

Optional short subtitle/description (e.g. "Start here: alphabet, reading, basics" – you can use placeholder text).

A list (or grid) of sub-lesson cards (LessonItem) underneath.

Each sub-lesson card shows:

Sub-lesson title (e.g. "Reading rules")

A small tick icon on the right:

Green when isCompleted == true

Grey/disabled when isCompleted == false

On tapping a sub-lesson card:

Navigate to the Lesson Detail Page for that sub-lesson.

The layout should fit nicely with the existing WordMap design (same padding, radius, typography rules as the rest of the app).

Lesson Detail Page (slide-based)

When a user taps a sub-lesson (e.g. "Reading rules"):

Open a full-screen LessonDetailPage for that LessonItem.

The page must include:

A close button (e.g. an X or back icon) in the top-left to return to the Lessons tab.

A big text area in the main body showing the current slide’s text.

A “Next” button at the bottom (or bottom-right) to go to the next slide.

Slide navigation behavior:

Start at slide index 0.

Next goes to the next slide.

When the user is on the last slide:

Next can change to a disabled state or be hidden.

The End-of-lesson actions (Completed / Repeat) must be visible.

End-of-lesson actions:

At the end (last slide), show two buttons:

Completed

Repeat again

Behavior:

Completed:

Set this lesson’s isCompleted = true in persistent storage.

Update the UI (so its tick becomes green in the Lessons tab).

Navigate back to the Lessons tab (pop the detail page).

Repeat again:

Reset the slide index to 0.

Stay in the lesson detail page and show the first slide again.

Implementation constraints

Do not change the structure of the Home or Profile tabs.

Integrate the Lessons tab into the existing bottom navigation (which already includes Lessons).

Keep the code clean and reusable:

Avoid copy-paste for each category/lesson.

Use the data model to generate UI.

No remote/network calls for this feature (everything is local).

Ensure the UI works in both light and dark mode (respecting the existing theme).

Acceptance criteria

The Lessons tab is available in the bottom navigation and opens a page with:

5 categories: Beginner Basics, Grammar, Useful Dialogues, Reading & Listening, Exam Practice.

Under Beginner Basics, there are at least 5 sub-lesson cards:

Alphabet

Reading rules

Parts of speech

Hallo

All about German

Tapping any Beginner Basics sub-lesson opens a slide-based LessonDetailPage.

The LessonDetailPage:

Has a close button.

Shows large explanatory text per slide.

Has a Next button to navigate slides.

On the last slide, shows “Completed” and “Repeat again”.

When the user taps “Completed”:

The lesson is marked as completed in persistent storage.

The user is returned to the Lessons tab.

The corresponding sub-lesson card shows a green tick.

Incomplete lessons show a grey/disabled tick.

Completion state persists across app restarts.

No regression in Home or Profile behavior.
