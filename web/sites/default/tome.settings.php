<?php

/**
 * @file
 * Tome configuration.
 */

$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/default/tome.services.yml';

$config['system.performance']['css']['preprocess'] = TRUE;
$config['system.performance']['js']['preprocess'] = TRUE;

$config['system.logging']['error_level'] = 'hide';

$settings['tome_static_directory'] = '../static-site';
