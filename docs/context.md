# WordMap – Project Context

This file gives the AI the essential background of the project.  
It MUST be loaded together with `/docs/index.md`.

---

## 1. Project Summary

WordMap is a German vocabulary learning app with:

- multi-language translations (DE → FA, EN, Finglish)
- pronunciation audio for each word
- categorized vocabulary structure (main categories + subcategories)
- onboarding for new vs experienced learners
- word cards with: DE, EN, FA, Finglish, Example, Photo, Audio
- bookmarking + viewed state
- simple, clean, iOS-like design philosophy
- offline-friendly (local storage for user progress)
- no user login in v1

---

## 2. Technologies Used

Frontend Framework:

- **Flutter (Dart)**

State Management (v1):

- **No global state library yet**
- Use simple state & setState or small local providers if needed
- If later needed, Riverpod may be added (not now)

Architecture:

- **Simple widget-driven architecture**
- Pages map directly to AppSchema
- Overlays are Flutter `(showModalBottomSheet / new route)` depending on complexity
- No complex navigation stack – only bottom navigation + one main page

Local Storage:

- Use **SharedPreferences** for simple persisted data:
  - viewed words
  - bookmarked words
  - settings (selected languages, theme, etc.)

Assets:

- `/assets/audio/`
- `/assets/images/`
- Fonts: SF Pro, fallback: system font
- Icons: Material Icons only

---

## 3. UX / UI Style Rules

Overall Style:

- iOS-inspired minimalism
- clean spacing
- soft shadows
- rounded corners
- light mode primary focus
- dark mode optional later

Word Card Rules:

- white background (normal)
- blue text + blue shadow (bookmarked)
- light grey background + grey text (viewed)
- fixed height, dynamic width based on content

Bottom Navigation:

- max 3 tabs: Home, Categories, Profile (or Settings)
- icons must be simple, Material icons
- labels optional depending on layout

Header Rules:

- centered title
- right-side action button (Settings or Profile)
- no left-side button unless needed for future features

Overlay Rules:

- Overlays are NOT separate pages
- Do not create new routes unless approved

---

## 4. Navigation Rules

Navigation is strictly defined by `app_schema.md`:

- All pages exist only inside `[Main Page]`
- Body area changes based on bottom tabs
- Overlays appear above parent pages
- AI MUST NOT introduce new routes without approval

---

## 5. Project Constraints

- NO authentication in v1
- MUST remain simple and fast
- DO NOT introduce complex services
- Offline-first where possible
- Avoid unnecessary libraries
- No backend yet (future versions may add Firebase)

---

## 6. Coding Style

General:

- Use `const` whenever possible
- Use descriptive widget names
- Avoid deeply nested widgets
- Break UI into small reusable widgets when possible
- Keep file structure flat inside `/lib/`

Naming:

- Files: `snake_case.dart`
- Widgets: `PascalCase`
- Variables & methods: `camelCase`
- Constants: `SNAKE_UPPERCASE`

Example:

word_card.dart
WordCard()
final bookmarkedWords = <String>[];

yaml
Code kopieren

---

## 7. Folder Structure (Flutter)

Recommended structure:

lib/
main.dart
features/
home/
words/
categories/
profile/
settings/
widgets/
word_card.dart
audio_button.dart
services/
storage_service.dart
audio_service.dart
theme/
colors.dart
text_styles.dart

yaml
Code kopieren

Rules:

- Features correspond directly to AppSchema containers
- Widgets folder contains reusable components
- Services contain logic not tied to UI

---

## 8. Internal Rules for AI

When generating code:

- DO NOT add new folders unless absolutely necessary
- DO NOT choose different state management unless explicitly asked
- DO NOT add new themes, fonts, or color systems
- DO NOT rename files or restructure project without approval

When updating navigation or structure:

- FIRST propose changes to AppSchema
- WAIT for user approval
- ONLY then modify code

---

## 9. Future-Proof Notes

Later versions may include:

- Firebase or Supabase backend
- Riverpod state management
- User accounts
- Cloud sync of progress
- AI word recommendations
- Exam modes

AI must not assume these features unless requested.
