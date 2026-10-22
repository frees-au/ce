<?php

/**
 * @file
 * Enforce settings desired for tome builds that conflict with local editing.
 *
 * @codingStandardsIgnoreFile
 *
 * @var array $settings
 * @var array $config
*/

$settings['twig_debug'] = FALSE;
$config['system.performance']['css']['preprocess'] = TRUE;
$config['system.performance']['js']['preprocess'] = TRUE;
$config['system.logging']['error_level'] = ERROR_REPORTING_HIDE;

error_reporting(0);
ini_set('display_errors', FALSE);
ini_set('display_startup_errors', FALSE);
