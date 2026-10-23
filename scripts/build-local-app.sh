#!/bin/bash

# Build the root-level frees-au-ce.app from the sources in scripts/local-app.
# Run this after changing the wrapper source, plist, supervisor, or site icon,
# or whenever the generated app needs to be recreated. It is not needed to
# launch the app during normal use.

set -euo pipefail

repository=$(cd "$(dirname "$0")/.." && pwd)
source_directory="$repository/scripts/local-app"
app="$repository/frees-au-ce.app"
contents="$app/Contents"
temporary_directory=$(mktemp -d "${TMPDIR:-/tmp}/frees-au-ce-build.XXXXXX")

cleanup() {
  rm -rf "$temporary_directory"
}
trap cleanup EXIT

mkdir -p "$contents/MacOS" "$contents/Resources"

CLANG_MODULE_CACHE_PATH="$temporary_directory/clang-modules" \
  /usr/bin/clang \
  -fobjc-arc \
  -O2 \
  -framework AppKit \
  -framework WebKit \
  "$source_directory/FreesLocal.m" \
  -o "$contents/MacOS/frees-au-ce"

cp "$source_directory/Info.plist" "$contents/Info.plist"
cp "$source_directory/supervise.sh" "$contents/Resources/supervise.sh"
chmod 755 "$contents/MacOS/frees-au-ce" "$contents/Resources/supervise.sh"

icon_source="$repository/web/themes/custom/fstheme/android-chrome-512x512.png"
cp "$icon_source" "$contents/Resources/AppIcon.png"

/usr/bin/codesign --force --deep --sign - "$app"
touch "$app"

echo "Built $app"
