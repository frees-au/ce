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
$config['system.performance']['css']['preprocess'] = FALSE;
$config['system.performance']['js']['preprocess'] = FALSE;
$config['system.logging']['error_level'] = ERROR_REPORTING_DISPLAY_VERBOSE;

error_reporting(0);
ini_set('display_errors', TRUE);
ini_set('display_startup_errors', TRUE);
