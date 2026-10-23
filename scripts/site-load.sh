#!/usr/bin/env bash
# Rebuild this local site from committed configuration and exported content.
set -euo pipefail
cd "$(dirname "$0")/.."

[[ -x vendor/bin/drush && -f config/sync/core.extension.yml && -d recipes/site_export/content ]] || {
  echo 'Install Composer dependencies and ensure config/sync and recipes/site_export/content exist.' >&2
  exit 1
}

mkdir -p database
if [[ ! -f database/live.sqlite ]]; then
  # SQLite sidecars can remain after the main database is deleted.
  rm -f database/live.sqlite-wal database/live.sqlite-shm
fi
# Do not silently reinstall over an existing site. An empty SQLite file can be
# created by Drush while inspecting an uninstalled site and is safe to use.
php <<'PHP'
<?php
if (is_file('database/live.sqlite')) {
  $db = new PDO('sqlite:database/live.sqlite');
  if ($db->query("SELECT COUNT(*) FROM sqlite_master WHERE type = 'table'")->fetchColumn() > 0) {
    fwrite(STDERR, "database/live.sqlite already contains tables. Remove it before rebuilding.\n");
    exit(1);
  }
}
PHP

# Active configuration is stored on disk here, so deleting SQLite alone does
# not give the installer the empty active configuration it requires.
mkdir -p config/live
find config/live -type f -name '*.yml' -delete

# These are generated derivatives. Remove thumbnails from the previous site
# before imported media entities recreate them during installation.
rm -rf web/sites/default/files/oembed_thumbnails

./vendor/bin/drush site:install --existing-config -y "$@"
./vendor/bin/drush content:import ../recipes/site_export/content

# Core's importer ignores the computed path field. Recreate the aliases recorded
# in the export against the newly assigned entity IDs.
./vendor/bin/drush php:eval "$(cat <<'PHP'
$finder = new \Drupal\Core\DefaultContent\Finder(dirname(DRUPAL_ROOT) . '/recipes/site_export/content');
$aliases = \Drupal::entityTypeManager()->getStorage('path_alias');
foreach ($finder->data as $uuid => $data) {
  foreach ($data['default']['path'] ?? [] as $path) {
    if (empty($path['alias'])) {
      continue;
    }
    $entity = \Drupal::service('entity.repository')->loadEntityByUuid($data['_meta']['entity_type'], $uuid);
    $values = [
      'path' => '/' . $entity->toUrl()->getInternalPath(),
      'alias' => $path['alias'],
      'langcode' => $path['langcode'] ?? $entity->language()->getId(),
    ];
    if (!$aliases->loadByProperties($values)) {
      $aliases->create($values)->save();
    }
  }
}
PHP
)"

# Some modules write installation defaults after the initial config import.
./vendor/bin/drush config:import -y

# Default content receives new numeric IDs. Use the homepage's exported alias
# instead of the old /home-route controller's hard-coded /node/4 fallback.
./vendor/bin/drush config:set system.site page.front /ce -y
./vendor/bin/drush cache:rebuild
echo 'Site installed and content imported. Run ./vendor/bin/drush uli to log in.'
