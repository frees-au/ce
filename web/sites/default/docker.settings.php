<?php

/**
 * @file
 * Local development settings, with dynamic settings for some dev environments.
 */

if (getenv('LANDO') === 'ON') {
  $lando_info = json_decode(getenv('LANDO_INFO'), TRUE);
  $databases['default']['default'] = [
    'driver' => 'mysql',
    'database' => $lando_info['database']['creds']['database'],
    'username' => $lando_info['database']['creds']['user'],
    'password' => $lando_info['database']['creds']['password'],
    'host' => $lando_info['database']['internal_connection']['host'],
    'port' => $lando_info['database']['internal_connection']['port'],
  ];
}

if (getenv('IS_DDEV_PROJECT') == 'true') {
  $databases['default']['default'] = [
    'driver' => 'mysql',
    'database' => 'db',
    'username' => 'db',
    'password' => 'db',
    'host' => 'db',
    'port' => 3306,
  ];
}

$settings['skip_permissions_hardening'] = TRUE;
$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/default/docker.services.yml';

$settings['twig_debug'] = FALSE;
$config['system.performance']['css']['preprocess'] = FALSE;
$config['system.performance']['js']['preprocess'] = FALSE;
$config['system.logging']['error_level'] = ERROR_REPORTING_DISPLAY_VERBOSE;

// Beware of xdebug slowness.
$settings['cache']['bins']['render'] = 'cache.backend.null';
$settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';
$settings['cache']['bins']['page'] = 'cache.backend.null';
// Extreme debugging.
$settings['cache']['bins']['discovery'] = 'cache.backend.null';
$settings['cache']['bins']['container'] = 'cache.backend.null';
$settings['cache']['bins']['bootstrap'] = 'cache.backend.null';

error_reporting(E_ALL);
ini_set('display_errors', TRUE);
ini_set('display_startup_errors', TRUE);

$settings['update_free_access'] = FALSE;
$settings['rebuild_access'] = FALSE;
