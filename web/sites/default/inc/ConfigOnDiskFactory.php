<?php

namespace Freesau\Config;

use Drupal\Core\Config\FileStorage;
use Drupal\Core\Site\Settings;

/**
 * Supplies the same writable file storage before and after kernel bootstrap.
 */
final class ConfigOnDiskFactory {

  /**
   * Creates active storage without requiring the service container.
   */
  public static function get($class_loader = NULL): FileStorage {
    return new FileStorage(Settings::get('config_active_directory'));
  }

}
