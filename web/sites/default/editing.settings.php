<?php

/**
 * @file
 * Local development settings, with dynamic settings for some dev environments.
 */

$settings['skip_permissions_hardening'] = TRUE;
$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/default/editing.services.yml';

$settings['twig_debug'] = FALSE;
// $config['system.performance']['css']['preprocess'] = FALSE;
// $config['system.performance']['js']['preprocess'] = FALSE;
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

// Stage file proxy. Please enable only stage_file_proxy module on non-prod env.
$config['stage_file_proxy.settings']['origin'] = 'https://frees.au';
$config['stage_file_proxy.settings']['verify'] = TRUE;
$config['stage_file_proxy.settings']['use_imagecache_root'] = TRUE;
$config['stage_file_proxy.settings']['hotlink'] = FALSE;
$config['stage_file_proxy.settings']['origin_dir'] = 'sites/default/files';
