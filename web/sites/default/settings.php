<?php

/**
 * @file
 * Drupal settings.
 *
 * @see https://api.drupal.org/api/drupal/sites!default!default.settings.php/11
 *
 * @codingStandardsIgnoreFile
 *
 * @var array $settings
 * @var array $databases
 * @var string $app_root
 * @var string $site_path
*/

$here = $app_root . '/' . $site_path;

// These settings would be a security risk in many implementations of Drupal.
$settings['hash_salt'] = 'n/a';
$settings['trusted_host_patterns'] = ['.*'];

$settings['update_free_access'] = FALSE;
$settings['rebuild_access'] = FALSE;
$settings['file_scan_ignore_directories'] = ['node_modules', 'bower_components',];
$settings['entity_update_batch_size'] = 50;
$settings['entity_update_backup'] = TRUE;
$settings['skip_permissions_hardening'] = TRUE;
$settings['file_public_path'] = 'sites/default/files';
$settings['file_private_path'] = 'sites/default/files/private';
$settings['file_temp_path'] = '/tmp';
$settings['container_yamls'][] = "{$here}/services.yml";

// Config runs off disk.
$settings['config_sync_directory'] = '../config/sync';
$settings['config_exclude_modules'] = ['devel'];

// Caching runs off disk.
$settings['php_storage']['default']['directory'] = "{$app_root}/sites/default/files/php";
$settings['cache']['default'] = 'cache.backend.php';

// Database is committed and runs of disk.
$databases['default']['default'] = [
  'driver' => 'sqlite',
  'database' => $app_root . '/../database/live.sqlite',
];

// Tome builds should pass --uri
$domain = ($_SERVER['SERVER_NAME'] ?? 'probably-not-tome');
switch ($domain) {
  case 'www.frees.au':
  case 'preview.frees.au':
    require_once "{$here}/tome.settings.php";
    $settings['tome_static_directory'] = "../html/{$domain}";
    break;
  default:
    $settings['container_yamls'][] = "{$here}/edit.services.yml";
    require_once "{$here}/edit.settings.php";
    break;
}

// Not in git, so knock yourself out.
if (file_exists("{$here}/env.settings.php")) {
  include_once "{$here}/env.settings.php";
}
