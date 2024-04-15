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
 */

$databases = [];
$settings['hash_salt'] = 'n/a'; // Overridden on Platform.sh
$settings['update_free_access'] = FALSE;
$settings['file_scan_ignore_directories'] = ['node_modules', 'bower_components',];
$settings['entity_update_batch_size'] = 50;
$settings['entity_update_backup'] = TRUE;
$settings['config_sync_directory'] = '../config/sync';
$settings['skip_permissions_hardening'] = TRUE; // @see fs_requirements_alter().
$settings['trusted_host_patterns'] = ['.*']; // Best practice for Platform.sh.
$settings['file_public_path'] = 'sites/default/files';
$settings['file_private_path'] = 'sites/default/files/private';
$settings['file_temp_path'] = '/tmp';

// These modules' config will never be imported/exported.
$settings['config_exclude_modules'] = [
  'fs_test', // @see fs_test_requirements() where it is also prevented to install on production.
  'default_content',
  'devel',
];

// Platform.sh. The code check is a copypasta catch-all.
if (getenv('PLATFORM_PROJECT') == 'fw7ucnhzydcsy') {
  include_once $app_root . '/' . $site_path . '/platformsh.settings.php';
}

// Pick your local poison. You're welcome to add others if they fit neatly into that file.
if (getenv('LANDO') == 'ON' || getenv('IS_DDEV_PROJECT') == 'true') {
  include_once $app_root . '/' . $site_path . '/docker.settings.php';
}

// Not in git and knock yourself out.
if (file_exists($app_root . '/' . $site_path . '/local.settings.php')) {
  include_once $app_root . '/' . $site_path . '/local.settings.php';
}
