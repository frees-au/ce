#!/usr/bin/env bash
# Export the current site as the local site template.
set -euo pipefail
cd "$(dirname "$0")/.."

[[ -x vendor/bin/drush ]] || {
  echo 'Install Composer dependencies before exporting the site.' >&2
  exit 1
}

./vendor/bin/drush site:export "$PWD/recipes/site_export" --overwrite --no-assets "$@"
