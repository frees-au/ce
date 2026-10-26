#!/usr/bin/env bash
# Export the current site as the local site template.
set -euo pipefail
cd "$(dirname "$0")/.."

[[ -x vendor/bin/drush ]] || {
  echo 'Install Composer dependencies before exporting the site.' >&2
  exit 1
}

# The search index is client-side, so it is not part of the exported recipe.
# Rebuild it anyway, so that a saved site is always left fully indexed.
# shellcheck source=scripts/includes/reindex-search.sh
source scripts/includes/reindex-search.sh
reindex_search content

./vendor/bin/drush config:export --yes

rm -Rf ./recipes/site_export/*
./vendor/bin/drush site:export "$PWD/recipes/site_export" --overwrite --no-assets --quiet "$@"
# Config is handled in sync and we don't need any duplicated.
rm -Rf ./recipes/site_export/config
# Oembed files get doubled up, so until we have files to include, or other dependencies, then we skill all files.
rm -Rf ./recipes/site_export/content/file
