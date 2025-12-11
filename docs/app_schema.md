=========================
CORE STRUCTURE – WordMap
=========================

[Main Page]
"Root page with header, dynamic body, and bottom navigation."

    [Header]
        =App title "WordMap" (centered)
        -settings "open profile/settings"

    [Body]
        "Body switches between tabs: Home, Lessons, Profile."

        [Home]
            "Default tab when app opens. Shows current words."

            [Words list]
                -[Word items]
                    (Word page)
                        =Word (de)
                        =Translation Fa
                        =Translation En
                        =Finglish
                        =Photo
                        =Example sentence
                        -play
                        -bookmark
                        -close

        [Lessons]
            [Lessons list]
                -[Lessons item]
                    [Sub Lessons list]
                        -[Sub Lessons item]
                            [Pages] "in pages start a lesson , can user next or close , maybe 1 or more pages"


        [Profile]
            [Profile & Settings content]
                -Words overview
                -translation options
                -about

    [Bottom]
        -[Home]
        -[Lessons]
        -[Profile]

=========================
OPTIONAL / EXTRA FEATURES (END SECTION)
=========================

[Onboarding]
=Question "Are you new to German learning?"
-new user
-experienced
-continue

[How to Read]
=Explanation blocks "German sound rules"
-play examples
-close

[Search]
-search input
[Search results] -[Word item]
(Word page)

[Bookmarks Page]
[Bookmarks list] -[Word item]
(Word page)

[Settings Page]
-translation mode
-theme mode
-reset data

[Notifications]
=Notification settings
-enable reminders
-disable reminders
