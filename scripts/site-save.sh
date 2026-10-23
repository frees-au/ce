#!/usr/bin/env bash
# Export the current site as the local site template.
set -euo pipefail
cd "$(dirname "$0")/.."

[[ -x vendor/bin/drush ]] || {
  echo 'Install Composer dependencies before exporting the site.' >&2
  exit 1
}

./vendor/bin/drush config:export --yes
./vendor/bin/drush site:export "$PWD/recipes/site_export" --overwrite --no-assets "$@"
# Config is handled in sync and we don't need any duplicated.
rm -Rf ./recipes/site_export/config
# Oembed files get doubled up, so until we have files to include, or other dependencies, then we skill all files.
rm -Rf ./recipes/site_export/content/file
