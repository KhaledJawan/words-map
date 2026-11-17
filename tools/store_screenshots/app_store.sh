#!/bin/zsh
# App Store screenshots from the iOS simulators, through the debug build's WORDSMAP_SCREEN hook.
# Every shot starts from the same app data (demo_state.py), so the order doesn't matter.
HERE=${0:A:h}
RAW=$1
ONLY=$2  # optional: p63, p69a, p69b or p61 to retake one device
APP=$(ls -d ~/Library/Developer/Xcode/DerivedData/iosApp-*/Build/Products/Debug-iphonesimulator/WordsMap.app | head -1)
mkdir -p $RAW

run_device() {
  local D=$1 NAME=$2
  [[ -n $ONLY && $ONLY != $NAME ]] && return
  xcrun simctl boot $D 2>/dev/null
  xcrun simctl bootstatus $D -b >/dev/null 2>&1
  xcrun simctl install $D "$APP"
  xcrun simctl status_bar $D override --time "9:41" --dataNetwork wifi --wifiMode active --wifiBars 3 --cellularMode active --cellularBars 4 --batteryState discharging --batteryLevel 100
  # shot <language> <screen> <file> [highlight]
  shot() {
    xcrun simctl terminate $D dev.nefrin.wordsmap 2>/dev/null
    python3 -I $HERE/demo_state.py ios $1 $D $4
    SIMCTL_CHILD_WORDSMAP_SCREEN="$2" xcrun simctl launch $D dev.nefrin.wordsmap >/dev/null
    sleep 9
    xcrun simctl io $D screenshot "$RAW/$NAME-$3.png" >/dev/null 2>&1
    echo "$NAME $3"
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
  shot en "text:a1/der-kater-carlo" 08-reading highlight
  shot en lessons 09-lessons
  shot fa learn 10-learn-farsi
  xcrun simctl terminate $D dev.nefrin.wordsmap 2>/dev/null
  xcrun simctl status_bar $D clear
}

run_device 69F1177E-E36F-466E-8C17-C4C3A97CF5F6 p63   # iPhone 17 Pro: 6.3-inch
run_device A51C3038-5114-420C-AEAF-D528403977A3 p69a  # iPhone 17 Pro Max: 6.9-inch 1320×2868
run_device E2C965C0-D3D6-49AD-A7C1-32B641DB4C75 p69b  # iPhone 16 Plus: 6.9-inch 1290×2796, also 6.5-inch
run_device 659D279C-60BB-4198-BF23-557FA2E574F1 p61   # iPhone 16: 6.1-inch
for D in 69F1177E-E36F-466E-8C17-C4C3A97CF5F6 A51C3038-5114-420C-AEAF-D528403977A3 E2C965C0-D3D6-49AD-A7C1-32B641DB4C75 659D279C-60BB-4198-BF23-557FA2E574F1; do xcrun simctl shutdown $D 2>/dev/null; done
echo DONE
