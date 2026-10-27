#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_ICON="$REPO_ROOT/docs/google-play/assets/app-icon-1024.png"

if ! command -v sips >/dev/null 2>&1; then
  echo "macOS sips is required to resize launcher icons." >&2
  exit 1
fi

ANDROID_RES="$REPO_ROOT/android/app/src/main/res"
for entry in "mdpi 48" "hdpi 72" "xhdpi 96" "xxhdpi 144" "xxxhdpi 192"; do
  read -r density pixels <<<"$entry"
  sips -z "$pixels" "$pixels" "$SOURCE_ICON" --out "$ANDROID_RES/mipmap-$density/ic_launcher.png" >/dev/null
done

IOS_ICON_DIR="$REPO_ROOT/ios/Runner/Assets.xcassets/AppIcon.appiconset"
while read -r filename pixels; do
  sips -z "$pixels" "$pixels" "$SOURCE_ICON" --out "$IOS_ICON_DIR/$filename" >/dev/null
done <<'ICON_SIZES'
Icon-App-20x20@1x.png 20
Icon-App-20x20@2x.png 40
Icon-App-20x20@3x.png 60
Icon-App-29x29@1x.png 29
Icon-App-29x29@2x.png 58
Icon-App-29x29@3x.png 87
Icon-App-40x40@1x.png 40
Icon-App-40x40@2x.png 80
Icon-App-40x40@3x.png 120
Icon-App-60x60@2x.png 120
Icon-App-60x60@3x.png 180
Icon-App-76x76@1x.png 76
Icon-App-76x76@2x.png 152
Icon-App-83.5x83.5@2x.png 167
Icon-App-1024x1024@1x.png 1024
ICON_SIZES

sips -z 512 512 "$SOURCE_ICON" --out "$REPO_ROOT/docs/google-play/assets/app-icon-512.png" >/dev/null
echo "Updated Android and iOS launcher icons and exported the Google Play 512 px icon."
