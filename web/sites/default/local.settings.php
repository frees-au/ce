<?php

/**
 * @file
 * SQLite development with config on disk.
 */

$settings['skip_permissions_hardening'] = TRUE;
$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/default/local.services.yml';

// This allows config editing straight to disk.
require_once $app_root . '/' . $site_path . '/inc/ConfigOnDiskFactory.php';
$settings['config_active_directory'] = $app_root . '/../config/active';
$settings['bootstrap_config_storage'] = ['Freesau\\Config\\ConfigOnDiskFactory', 'get'];

$settings['twig_debug'] = FALSE;
$config['system.performance']['css']['preprocess'] = FALSE;
$config['system.performance']['js']['preprocess'] = FALSE;
$config['system.logging']['error_level'] = ERROR_REPORTING_DISPLAY_VERBOSE;

$settings['php_storage']['default']['directory'] = $app_root .'/sites/default/files/php';
$settings['cache']['default'] = 'cache.backend.php';

error_reporting(E_ALL & ~E_DEPRECATED & ~E_USER_DEPRECATED);
ini_set('display_errors', TRUE);
ini_set('display_startup_errors', TRUE);

$settings['update_free_access'] = FALSE;
$settings['rebuild_access'] = FALSE;

// --uri from Drush.
$settings['tome_static_directory'] = '../html/' . ($_SERVER['SERVER_NAME'] ?? 'www.frees.au');

// Replace cache_container in the db.
$settings['bootstrap_container_definition'] = [
  'parameters' => [],
  'services' => [
    'database' => [
      'class' => 'Drupal\Core\Database\Connection',
      'factory' => 'Drupal\Core\Database\Database::getConnection',
      'arguments' => ['default'],
    ],
    'request_stack' => [
      'class' => 'Symfony\Component\HttpFoundation\RequestStack',
    ],
    'datetime.time' => [
      'class' => 'Drupal\Component\Datetime\Time',
      'arguments' => ['@request_stack'],
    ],
    'cache_tags_provider.container' => [
      'class' => 'Drupal\Core\Cache\DatabaseCacheTagsChecksum',
      'arguments' => ['@database'],
    ],
    'cache.container' => [
      'class' => 'Drupal\Core\Cache\PhpBackend',
      'arguments' => [
        'container',
        '@cache_tags_provider.container',
        '@datetime.time',
      ],
    ],
  ],
];
