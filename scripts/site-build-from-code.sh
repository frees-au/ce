#!/usr/bin/env bash
# Rebuild this local site from committed configuration and exported content.
set -euo pipefail
cd "$(dirname "$0")/.."

local_host=127.0.0.1
local_port=${CE_LOCAL_PORT:-8888}
if ! [[ "$local_port" =~ ^[0-9]+$ ]] || (( local_port < 1 || local_port > 65535 )); then
  echo "Invalid local site port: $local_port" >&2
  exit 1
fi

if ! php -r '
  $socket = @stream_socket_server("tcp://{$argv[1]}:{$argv[2]}", $error_code, $error_message);
  if (!$socket) {
    exit(1);
  }
  fclose($socket);
' "$local_host" "$local_port"; then
  echo "Local site port $local_host:$local_port is already in use, stubbornly assuming you don't want two servers at once." >&2
  exit 1
fi

[[ -x vendor/bin/drush && -f config/sync/core.extension.yml && -d recipes/site_export/content ]] || {
  echo 'Install Composer dependencies and ensure config/sync and recipes/site_export/content exist.' >&2
  exit 1
}

mkdir -p database
if [[ -f database/live.sqlite ]]; then
  if ! read -r -p 'Would you like to back up the previous live database? [y/N] ' backup_database; then
    echo >&2
    echo 'No response received. Site load cancelled.' >&2
    exit 1
  fi

  case "$backup_database" in
    [yY]|[yY][eE][sS])
      backup="database/live-backup-$(date '+%Y%m%d-%H%M%S').sqlite"
      while [[ -e "$backup" || -e "$backup-wal" || -e "$backup-shm" ]]; do
        backup="database/live-backup-$(date '+%Y%m%d-%H%M%S')-$RANDOM.sqlite"
      done
      mv database/live.sqlite "$backup"
      [[ ! -e database/live.sqlite-wal ]] || mv database/live.sqlite-wal "$backup-wal"
      [[ ! -e database/live.sqlite-shm ]] || mv database/live.sqlite-shm "$backup-shm"
      echo "Previous live database moved to $backup."
      ;;
    *)
      echo 'Site load cancelled; database/live.sqlite was not changed.'
      exit 1
      ;;
  esac
else
  # SQLite sidecars can remain after the main database is deleted.
  rm -f database/live.sqlite-wal database/live.sqlite-shm
fi

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
echo 'Site installed and content imported.'

if [[ -t 0 ]]; then
  echo 'User 1 login link:'
  ./vendor/bin/drush user:login --uid=1 --no-browser user/1
  echo

  if read -r -p 'Start the local site and open it in your browser? [y/N] ' serve_site; then
    case "$serve_site" in
      [yY]|[yY][eE][sS])
        echo 'Starting the local site in the foreground. Press Ctrl+C to stop it.'
        exec ./vendor/bin/drush serve /
        ;;
    esac
  else
    echo
  fi
fi

echo 'Run ./vendor/bin/drush serve / to start the site, or ./vendor/bin/drush uli to log in.'
