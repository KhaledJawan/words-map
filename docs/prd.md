=========================
PRD – WordMap (Product Requirements)
=========================

Overview:
WordMap is a multilingual German vocabulary learning app with:

- DE → EN → FA → Finglish
- Photos + audio for each word
- Categories + Subcategories
- Home/Words, Categories, Profile tabs
- Word Detail as overlay
- Fast UI (no full refresh)

User Goals:

- Quick learning (20 words/day)
- Personalizable translations
- Bookmark + Viewed system
- Smooth scrolling (60fps)
- Beginner onboarding with pronunciation tutorial

Key Features:

1. Word Cards

   - Show word, translations, finglish, photo, example
   - Play audio instantly
   - Bookmark toggle
   - Viewed auto-activation

2. Word Detail Overlay

   - Opens when tapping a word
   - All data visible
   - No navigation route change

3. Categories

   - Category → Subcategory → Words

4. Profile

   - Translation mode (EN, FA, Both, Finglish)
   - How to Read tutorial
   - About section

5. Beginner Support
   - Onboarding: new vs experienced
   - “How to Read” page before Main Page if new user
   - Reopenable from Profile

Technical Requirements:

- Local storage for translations mode, bookmarks, viewed words, onboarding state
- Audio playback < 200ms
- Smooth UI updates (no full page refresh)
- Offline-first data

Constraints:

- No login required in v1
- BottomNav only inside Main Page
