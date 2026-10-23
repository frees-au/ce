<?php

/**
 * @file
 * Removes regenerable oEmbed thumbnail file entities from a site export.
 */

declare(strict_types=1);

use Symfony\Component\Yaml\Yaml;

require dirname(__DIR__) . '/vendor/autoload.php';

$directory = $argv[1] ?? '';
if (!is_dir($directory)) {
  fwrite(STDERR, "Expected an exported file-content directory.\n");
  exit(1);
}

$removed_payloads = [];
$remaining_payloads = [];
$removed_entities = 0;

foreach (glob($directory . '/*.yml') ?: [] as $path) {
  $data = Yaml::parseFile($path);
  $uri = $data['default']['uri'][0]['value'] ?? '';
  $filename = $data['default']['filename'][0]['value'] ?? '';

  if (str_starts_with($uri, 'public://oembed_thumbnails/')) {
    if ($filename !== '') {
      $removed_payloads[$filename] = TRUE;
    }
    unlink($path);
    $removed_entities++;
  }
  elseif ($filename !== '') {
    $remaining_payloads[$filename] = TRUE;
  }
}

foreach (array_diff_key($removed_payloads, $remaining_payloads) as $filename => $_) {
  $path = $directory . '/' . $filename;
  if (is_file($path)) {
    unlink($path);
  }
}

printf("Removed %d generated oEmbed thumbnail file entities from the export.\n", $removed_entities);
