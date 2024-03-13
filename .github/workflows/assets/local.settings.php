<?php

/**
 * @file
 * Drupal settings file used in Github e2e action.
 */

error_reporting(E_ALL ^ E_DEPRECATED);
ini_set('display_errors', TRUE);
ini_set('display_startup_errors', TRUE);
$settings['update_free_access'] = FALSE;
$settings['rebuild_access'] = FALSE;
$settings['skip_permissions_hardening'] = TRUE;

$databases['default']['default'] = [
  'driver' => 'mysql',
  'database' => 'test_db',
  'username' => 'test_user',
  'password' => 'test_password',
  'host' => 'mariadb',
  'port' => 3306,
];
