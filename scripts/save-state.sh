#!/usr/bin/env bash
# Export active configuration and compact the site's committed SQLite database.
set -euo pipefail
cd "$(dirname "$0")/.."
./vendor/bin/drush config:export -y
php <<'PHP'
<?php
require 'vendor/autoload.php';
$path = 'database/live.sqlite';
$db = new PDO('sqlite:' . $path);
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
$db->sqliteCreateCollation('NOCASE_UTF8', ['Drupal\Component\Utility\Unicode', 'strcasecmp']);
$db->beginTransaction();
foreach (['config_export', 'config_import'] as $table) {
  if ($db->query("SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name = '$table'")->fetchColumn()) {
    $db->exec('DELETE FROM ' . $table);
  }
}
$db->commit();
$db->exec('VACUUM');
$result = $db->query('PRAGMA integrity_check')->fetchColumn();
if ($result !== 'ok') {
  throw new RuntimeException('SQLite integrity check failed: ' . $result);
}
clearstatcache(true, $path);
printf("SQLite integrity: ok; size: %.2f MB\n", filesize($path) / 1048576);
if (filesize($path) > 10 * 1048576) {
  fwrite(STDERR, "Warning: database/live.sqlite exceeds 10 MB.\n");
}
PHP
git status --short -- config/sync database/live.sqlite
