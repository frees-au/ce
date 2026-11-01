#!/usr/bin/env bash
# Rebuild the client-side Lunr search index from scratch.
#
# search_api_lunr is a client-side search engine: PHP writes JSON shards under
# public://search-api-js/<server>/<index>/ and the browser downloads them and
# builds the Lunr index in JavaScript. The browser is handed the list of files
# that exist at page render time, so a rebuild has to finish before the site
# is rendered or exported.
#
# Sourced by site-export-to-code.sh and site-generate-static.sh.

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
  ' ${drush_args[@]+"${drush_args[@]}"}

  # Mark every item as pending, then index everything that is left.
  ./vendor/bin/drush search-api:reset-tracker "$index_id" ${drush_args[@]+"${drush_args[@]}"}
  ./vendor/bin/drush search-api:index "$index_id" ${drush_args[@]+"${drush_args[@]}"}

  # A zero-length or partially written shard makes every browser search fail
  # when Response.json() reads it. Search API can still report 100% indexed in
  # that state, so validate the generated client-side files before an export is
  # allowed to continue.
  SEARCH_INDEX_ID="$index_id" ./vendor/bin/drush php:eval '
    $id = getenv("SEARCH_INDEX_ID");
    $index = \Drupal\search_api\Entity\Index::load($id);
    $server_id = $index->getServerId();
    $directory = \Drupal::service("file_system")->realpath("public://search-api-js/$server_id/$id");
    $files = $directory === FALSE ? [] : glob($directory . "/index-*.json");
    if (!$files) {
      fwrite(STDERR, "Lunr index \"$id\" did not generate any JSON shards.\n");
      exit(1);
    }
    foreach ($files as $file) {
      $contents = file_get_contents($file);
      try {
        $data = json_decode($contents, TRUE, 512, JSON_THROW_ON_ERROR);
      }
      catch (\JsonException $exception) {
        fwrite(STDERR, basename($file) . ": " . $exception->getMessage() . "\n");
        exit(1);
      }
      if (!is_array($data)) {
        fwrite(STDERR, basename($file) . ": expected a JSON object.\n");
        exit(1);
      }
    }
    print "Validated " . count($files) . " Lunr JSON shards.\n";
  ' ${drush_args[@]+"${drush_args[@]}"}
}
