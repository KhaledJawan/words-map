Task UI-01 – Implement Main Page with bottom navigation (Home, Lessons, Profile + Settings inside Profile)
Goal

Implement the [Main Page] structure from /docs/app_schema.md by adding a bottom navigation bar with three tabs:

Home

Lessons

Profile

The current main screen (existing words list / main content) must become the content of the Home tab, without changing its logic or visual style (except necessary refactoring to fit into the new structure).

The Profile tab will contain both:

“Profile” content (user-related info / placeholder), and

a “Settings” section (placeholder options).

So we do NOT have a separate “Settings” tab in the bottom bar. Settings lives inside the Profile page.

Context

From /docs/app_schema.md:

[Main Page] is the root page with:

[Header] (App title "WordMap" + settings/profile icon)

[Body] that switches between tabs: [Home], [Lessons], [Profile]

[Bottom] with the bottom navigation bar

[Home] is the default tab and shows the current words view.

[Lessons] and [Profile] exist as containers but may not yet be implemented in code.

We want:

A single root page that owns the Scaffold and BottomNavigationBar.

The existing main screen content to be used as [Home] body.

A Lessons tab as a placeholder for future lessons.

A Profile tab that internally shows both:

profile info area, and

a list of settings items (e.g. language, theme) as placeholders.

Implementation Steps

Follow these steps, adapting names to match the existing codebase:

Find the current entry point and main page

Locate main.dart and the top-level MaterialApp.

Identify the current “main page” widget that shows the word list (this is the app’s current home screen).

Extract current main content into a Home widget

Create a new widget, e.g. HomeTab or HomeScreen, that contains ONLY the main body of the current screen (word list, filters, etc.), without its own Scaffold.

Move the existing body content into this Home widget.

Ensure behavior (scrolling, bookmarks, viewed words, etc.) stays the same.

Create a root MainPage with header + bottom navigation

Create a new StatefulWidget, e.g. MainPage or RootPage, that will be set as home: of the MaterialApp.

This widget should:

Use a single Scaffold.

Define an AppBar (or header) according to [Header] in app_schema.md:

Centered title "WordMap".

A profile/settings icon button on the right that switches to the Profile tab when tapped.

Hold an int currentIndex for the selected tab.

Provide a BottomNavigationBar with three items:

Home with a home icon.

Lessons with a lessons/book icon.

Profile with a person/account icon.

On tap of a bottom item, update currentIndex with setState.

Create tab widgets and wire them

Home tab

For Home tab: render the extracted Home widget (the existing main content).

Lessons tab

Create a simple placeholder widget (e.g. LessonsTab) that matches the [Lessons] container from app_schema.md.

This can be minimal for now, such as:

A basic ListView with a few placeholder items, or

Center(Text('Lessons coming soon')).

Profile tab (Profile + Settings inside one page)

Create a widget, e.g. ProfileTab, mapped to the [Profile] container in app_schema.md.

Inside this widget, structure the UI roughly as:

A “Profile” section at the top (e.g. user avatar placeholder, name/email placeholders, or a simple header like “Profile”).

A “Settings” section below, implemented as a ListView or ListView with ListTile items, for example:

“Language”

“Theme”

“Notifications”

The Settings items can be non-functional placeholders for now, but they must be clearly visible.

Keep the design simple and consistent with the rest of the app (Material, current theme).

The MainPage body should switch between:

HomeTab

LessonsTab

ProfileTab
based on currentIndex.

Update MaterialApp to use the new root page

In main.dart, set the home: of MaterialApp to the new MainPage (or equivalent).

Do not change theme or global configuration unless required for this task.

Header interaction

In the header of MainPage, the profile/settings icon button should change the selected tab to the Profile tab when tapped (e.g. set currentIndex = 2 via setState).

Respect existing design & performance

Keep the Home tab behavior and layout as close as possible to the current implementation.

Avoid unnecessary rebuilds or full refreshes beyond what is needed to switch tabs.

Do not introduce new state management libraries.

Error handling and safety

Follow /docs/error_handling_rules.md for any new potential error states.

Since this task is mostly UI structure, avoid adding new error flows unless strictly needed.

Acceptance Criteria

The app now starts on the new MainPage with:

A header showing "WordMap" and a profile/settings icon.

A BottomNavigationBar with three tabs: Home, Lessons, Profile.

The Home tab:

Shows the same content as the previous main screen (word list etc.).

Behavior and logic are preserved.

The Lessons tab:

Shows a basic placeholder view consistent with the [Lessons] container (simple but present and reachable).

The Profile tab:

Exists as a separate tab in the bottom navigation.

Contains both:

A “Profile” section (header + placeholder info), and

A “Settings” section with at least a few visible settings items (placeholders).

The profile/settings icon in the header switches to this tab when tapped.

No files in /docs are modified.

The project compiles successfully and runs without new errors or warnings introduced by this task.

At the end, show the concrete code changes (files and diffs) you made.
