<?php

declare(strict_types=1);

namespace Drupal\fs_tools\EventSubscriber;

use Drupal\Core\DefaultContent\PreExportEvent;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;

/**
 * Preserves content timestamps in Default Content exports.
 *
 * Drupal core deliberately excludes fields of the `created` and `changed`
 * types from Default Content exports. That default is appropriate for seed
 * content, which is expected to be created when a recipe is installed, but it
 * means every item exported by `drush site:export` otherwise appears to have
 * been created and updated at the time the resulting site is built.
 *
 * This site uses its exported recipe as a portable representation of existing
 * content rather than as timeless seed content. Re-enabling these fields keeps
 * their original dates in the recipe YAML and allows the Default Content
 * importer to restore them when rebuilding the site.
 */
final class PreserveContentDatesSubscriber implements EventSubscriberInterface {

  /**
   * {@inheritdoc}
   */
  public static function getSubscribedEvents(): array {
    return [
      PreExportEvent::class => 'preserveContentDates',
    ];
  }

  /**
   * Re-enables timestamps after core has marked them as non-exportable.
   *
   * Field names differ between entity types, so this checks field types rather
   * than assuming the conventional `created` and `changed` names. The current
   * revision timestamp is also an entity revision metadata key and must be
   * enabled separately. This preserves the current exported revision's date;
   * recipes still do not contain an entity's complete revision history.
   */
  public function preserveContentDates(PreExportEvent $event): void {
    foreach ($event->entity->getFieldDefinitions() as $name => $definition) {
      if (in_array($definition->getType(), ['created', 'changed'], TRUE)) {
        $event->setExportable($name);
      }
    }

    $event->setEntityKeyExportable('revision_created');
  }

}
