#!/bin/sh
# Builds the App Store file of the iOS app: release/WordMap-<version>-<build>.ipa.
#
#     sh tools/build_ios_release.sh
#
# Upload the .ipa with Apple's Transporter app (or Xcode's Organizer). Raise
# CURRENT_PROJECT_VERSION in iosApp/Configuration/Config.xcconfig before every upload.
# Signing is automatic: Xcode must be signed in to the Apple ID of team 8HT2897WG7.
set -e
cd "$(dirname "$0")/.."

config=iosApp/Configuration/Config.xcconfig
version=$(sed -n 's/^MARKETING_VERSION *= *//p' "$config")
build=$(sed -n 's/^CURRENT_PROJECT_VERSION *= *//p' "$config")
archive=build/ios/WordMap.xcarchive
export_dir=build/ios/export

rm -rf "$archive" "$export_dir"
xcodebuild \
    -project iosApp/iosApp.xcodeproj \
    -scheme iosApp \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -archivePath "$archive" \
    -allowProvisioningUpdates \
    archive
xcodebuild \
    -exportArchive \
    -archivePath "$archive" \
    -exportOptionsPlist iosApp/ExportOptions.plist \
    -exportPath "$export_dir" \
    -allowProvisioningUpdates

mkdir -p release
cp "$export_dir"/*.ipa "release/WordMap-$version-$build.ipa"
echo "release/WordMap-$version-$build.ipa"
