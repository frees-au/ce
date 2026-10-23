#!/usr/bin/env bash
# Export the current site as the local site template.
set -euo pipefail
cd "$(dirname "$0")/.."

[[ -x vendor/bin/drush ]] || {
  echo 'Install Composer dependencies before exporting the site.' >&2
  exit 1
}

export_directory="$(mktemp -d "${TMPDIR:-/tmp}/frees-au-ce-site-export.XXXXXX")"
trap 'rm -rf "$export_directory"' EXIT

./vendor/bin/drush site:export "$export_directory" --no-assets "$@"
php scripts/prune-exported-oembed-thumbnails.php "$export_directory/content/file"
mkdir -p recipes/site_export
rsync -a --delete "$export_directory/" recipes/site_export/
