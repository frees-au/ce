<?php

// @dragonz This replaces cache_container in the db and I would not recommend doing this in most Drupal.
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
