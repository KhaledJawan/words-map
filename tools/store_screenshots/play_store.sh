#!/bin/bash
# Play Store screenshots on the emulator at 1080×1920, through the debug build's screen hook
# (the wordsmap.screen extra). Every shot starts from the same app data (demo_state.py).
export ANDROID_SERIAL=${ANDROID_SERIAL:-emulator-5554}
HERE=$(cd "$(dirname "$0")" && pwd)
RAW="$1"; APK="$2"
PKG=com.merlinict.wordmap
mkdir -p "$RAW/state"
python3 -I "$HERE/demo_state.py" android en > "$RAW/state/en.xml"
python3 -I "$HERE/demo_state.py" android en highlight > "$RAW/state/en-highlight.xml"
python3 -I "$HERE/demo_state.py" android fa > "$RAW/state/fa.xml"

adb wait-for-device
until [ "$(adb shell getprop sys.boot_completed | tr -d '\r')" = 1 ]; do sleep 2; done
# Play allows at most 2:1, so not the emulator's own 1080×2400.
adb shell wm size 1080x1920
adb install -r "$APK" >/dev/null
adb shell pm clear $PKG >/dev/null
adb shell pm grant $PKG android.permission.POST_NOTIFICATIONS
adb shell appops set $PKG SCHEDULE_EXACT_ALARM allow
# A clean status bar: 09:41, full battery and signal, no notification icons.
adb shell settings put global sysui_demo_allowed 1
for cmd in "enter" "clock -e hhmm 0941" "battery -e level 100 -e plugged false" "network -e wifi show -e level 4 -e fully true" "network -e mobile hide" "notifications -e visible false"; do
  set -- $cmd; adb shell am broadcast -a com.android.systemui.demo -e command "$@" >/dev/null
done

# shot <data> <screen> <file>
shot() {
  adb shell am force-stop $PKG
  adb shell run-as $PKG mkdir -p shared_prefs
  adb exec-in "run-as $PKG sh -c 'cat > shared_prefs/wordsmap.xml'" < "$RAW/state/$1.xml"
  adb shell am start -W -n $PKG/dev.nefrin.wordsmap.MainActivity --es wordsmap.screen "'$2'" >/dev/null
  sleep 10
  adb exec-out screencap -p > "$RAW/$3.png"
  echo "$3"
}
# The first start after installing is slow; let it finish before the real shots.
shot en "" warmup
shot en "" 01-home
shot en learn 02-learn
shot en learn-session 03-flashcards
shot en "word:wA1-1-0010" 04-word-card
shot en my-words 05-my-words
shot en bookmarks 06-bookmarks
shot en "grammar-lesson:a1/01-ich-du-er-sie-es-wir" 07-grammar-lesson
shot en-highlight "text:a1/der-kater-carlo" 08-reading
# Play takes 8 phone screenshots; these two are for comparing with the App Store set.
shot en lessons 09-lessons
shot fa learn 10-learn-farsi

adb shell am force-stop $PKG
adb shell am broadcast -a com.android.systemui.demo -e command exit >/dev/null
adb shell wm size reset
echo DONE
