#!/usr/bin/env bash
# Rebuild the client-side Lunr search index from scratch.
#
# search_api_lunr is a client-side search engine: PHP writes JSON shards under
# public://search-api-js/<server>/<index>/ and the browser downloads them and
# builds the Lunr index in JavaScript. The browser is handed the list of files
# that exist at page render time, so a rebuild has to finish before the site
# is rendered or exported.
#
# Sourced by site-save.sh and build-static.sh.

# Rebuilds the given search_api index completely.
#
#   reindex_search [index-id] [uri]
#
# The index is cleared first, not just re-indexed over: re-indexing rewrites
# the entry for every item that still exists, but an entry for an item that has
# since been deleted would otherwise stay in the shards and keep showing up in
# search results.
#
# Pass the URI of the build when there is one. settings.php selects a whole
# settings profile (and for a Tome build, the static export directory) from
# $_SERVER['SERVER_NAME'], so a drush run without --uri would load the wrong
# profile.
reindex_search() {
  local index_id="${1:-content}"
  local uri="${2:-}"

  local drush_args=()
  if [[ -n "$uri" ]]; then
    drush_args=(--uri="$uri")
  fi

  SEARCH_INDEX_ID="$index_id" ./vendor/bin/drush php:eval '
    $id = getenv("SEARCH_INDEX_ID");
    $index = \Drupal\search_api\Entity\Index::load($id);
    if ($index === NULL) {
      fwrite(STDERR, "Search API index \"$id\" does not exist.\n");
      exit(1);
    }
    if (!$index->status()) {
      fwrite(STDERR, "Search API index \"$id\" is disabled.\n");
      exit(1);
    }
    $index->getServerInstance()->getBackend()->deleteAllIndexItems($index);
  ' "${drush_args[@]}"

  # Mark every item as pending, then index everything that is left.
  ./vendor/bin/drush search-api:reset-tracker "$index_id" "${drush_args[@]}"
  ./vendor/bin/drush search-api:index "$index_id" "${drush_args[@]}"
}
