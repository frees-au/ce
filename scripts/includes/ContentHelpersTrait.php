<?php

declare(strict_types=1);

namespace FreeSauce\Ce\Scripts;

/**
 * Trait wrapper so Drush commands can `use ContentHelpersTrait;` directly.
 *
 * Commands get a lazily-instantiated ContentHelpers instance available as
 * `$this->helpers`. Intended for use inside custom Drush command classes
 * under drush/Commands/.
 */
trait ContentHelpersTrait {

  protected ?ContentHelpers $helpers = NULL;

  protected function helpers(): ContentHelpers {
    if ($this->helpers === NULL) {
      $this->helpers = new ContentHelpers();
    }
    return $this->helpers;
  }

}