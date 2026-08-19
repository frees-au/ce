<?php

/**
 * @file
 * Tome configuration.
 */

$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/default/tome.services.yml';

$config['system.performance']['css']['preprocess'] = TRUE;
$config['system.performance']['js']['preprocess'] = TRUE;

$databases['default']['default'] = [
  'driver' => 'sqlite',
  'database' => '/home/runner/frees-au-tome.sqlite',
];

$config['system.logging']['error_level'] = 'hide';

$host = $_SERVER['HTTP_HOST'] ?? $_SERVER['SERVER_NAME'] ?? '';
dump($host);
if ($host) {
  $settings['tome_static_directory'] = match ($host) {
    'www.frees.au' => '/home/runner/artifacts/frees-au-ce/prod',
    'www.freesau.cy' => '/home/runner/artifacts/frees-au-ce/local',
    default => throw new \RuntimeException("Unknown Tome host: $host"),
  };
}
