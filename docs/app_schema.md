=========================
CORE STRUCTURE – WordMap
=========================

[Main Page]
"Root page with header, dynamic body, and bottom navigation."

    [Header]
        -(Overview)wordCounter "Shows words readed / total words and click to open overview"
        -(Chapters)Category title "WordMap"
        -(Profile and settings)profile "open profile/settings"

    [Body]
        ""

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

        Overlay
            (Overview)
            (Chapters)
            (Profile and settings)




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
