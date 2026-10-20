<?php

/**
 * @file
 * Drupal settings entry point.
 *
 * The structure of the settings files is stipulate by Si. Feel free to reach
 * out to discuss. Basically DDev and Lando should just work. Filename structure
 * is foobar.settings.php so they sort with the corresponding service ymls.
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

$databases['default']['default'] = [
  'driver' => 'sqlite',
  'database' => $app_root . '/../database/live.sqlite',
];

$settings['hash_salt'] = 'n/a'; // Overridden on Platform.sh
$settings['update_free_access'] = FALSE;
$settings['file_scan_ignore_directories'] = ['node_modules', 'bower_components',];
$settings['entity_update_batch_size'] = 50;
$settings['entity_update_backup'] = TRUE;
$settings['skip_permissions_hardening'] = TRUE; // @see fs_requirements_alter().
$settings['trusted_host_patterns'] = ['.*']; // Best practice for Platform.sh.
$settings['file_public_path'] = 'sites/default/files';
$settings['file_private_path'] = 'sites/default/files/private';
$settings['file_temp_path'] = '/tmp';

$settings['config_sync_directory'] = '../config/active';

$settings['config_exclude_modules'] = [
  'devel',
];

include_once $app_root . '/' . $site_path . '/local.settings.php';

// Not in git and knock yourself out.
if (file_exists($app_root . '/' . $site_path . '/env.settings.php')) {
  include_once $app_root . '/' . $site_path . '/env.settings.php';
}
