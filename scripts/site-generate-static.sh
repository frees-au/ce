#!/usr/bin/env bash
set -euo pipefail

# Build the Tome static export using the first argument as the domain.
STATIC_OUTPUT_ROOT="${STATIC_OUTPUT_ROOT:-../ce-web-static}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

DOMAIN="${1:-www.frees.au}"
URI="${TOME_URI:-https://$DOMAIN}"

# The search index is client-side: the browser downloads JSON shards listed in
# the page's drupalSettings. The list is built when the page is rendered, so
# the index has to be complete before Tome renders anything.
source scripts/includes/reindex-search.sh
reindex_search content "$URI"

ENV=$([[ "$DOMAIN" == "www.frees.au" ]] && echo "www.frees.au" || echo "preview.frees.au")
export TOME_STATIC_DIRECTORY="${REPO_ROOT}/${STATIC_OUTPUT_ROOT}/${DOMAIN}"

vendor/bin/drush theme:dev off -vv --uri="$URI"
vendor/bin/drush cache:rebuild -vv --uri="$URI"
vendor/bin/drush tome:static -vv --uri="$URI"

# Tome only copies the files it happens to request while rendering, and the
# search index is fetched by the browser rather than by the exporter. Copy the
# shards into the export so the static site can serve them.
#
# The destination comes from Tome's own static directory rather than from a
# domain mapping here: settings.php sends www.frees.au and preview.frees.au to
# separate directories and everything else to the bare html/ directory. Every
# drush call runs with --uri so that the same settings profile is loaded as
# the one the export used.
INDEX_SOURCE="$(vendor/bin/drush php:eval 'print \Drupal::service("file_system")->realpath("public://search-api-js");' --uri="$URI")"
INDEX_PUBLIC_PATH="$(vendor/bin/drush php:eval 'print \Drupal::service("file_url_generator")->generateString("public://search-api-js");' --uri="$URI")"
STATIC_DIRECTORY="$(vendor/bin/drush php:eval 'print \Drupal::service("tome_static.generator")->getStaticDirectory();' --uri="$URI")"
if [[ "$STATIC_DIRECTORY" == /* ]]; then
  STATIC_DIRECTORY_PATH="$STATIC_DIRECTORY"
else
  STATIC_DIRECTORY_PATH="$REPO_ROOT/web/$STATIC_DIRECTORY"
fi
INDEX_DEST="$(cd "$STATIC_DIRECTORY_PATH" && pwd -P)$INDEX_PUBLIC_PATH"

if [[ -d "$INDEX_SOURCE" ]]; then
  rm -Rf "$INDEX_DEST"
  mkdir -p "$INDEX_DEST"
  cp -R "$INDEX_SOURCE/." "$INDEX_DEST/"
  echo "✓ Search index copied to $INDEX_DEST"
else
  echo "✗ No search index found at $INDEX_SOURCE" >&2
  exit 1
fi

echo
echo "✓ Static export written"
echo "  URI: $URI"
echo "  Directory: $TOME_STATIC_DIRECTORY"
