<?php

declare(strict_types=1);

namespace FreeSauce\Ce\Scripts;

use Drupal\block\Entity\Block;
use Drupal\Core\Entity\EntityInterface;
use Drupal\node\Entity\Node;

/**
 * Reusable helpers for building Free Sauce / frees.au content.
 *
 * Modelled on Drupal core's {@see \Drupal\Tests\block\Traits\BlockCreationTrait}:
 * each helper returns the created entity, defaults are merged with the caller
 * via `+=`, and config is read from the live container (Drupal::configFactory(),
 * Drupal::entityTypeManager()) — never hardcoded.
 *
 * Usage from a Drush command or one-off PHP script:
 *
 *   $helpers = new ContentHelpers();
 *   $node = $helpers->createNode('article', [
 *     'title' => 'Hello world',
 *     'body' => ['value' => 'Lorem ipsum.', 'format' => 'basic_html'],
 *   ]);
 *
 * Or as a trait-style mixin: declare `use ContentHelpersTrait;` in your command.
 */
final class ContentHelpers {

  /**
   * Creates a node with sensible defaults.
   *
   * @param string $bundle
   *   Node bundle machine name (e.g. 'article', 'page').
   * @param array $values
   *   Field values keyed by field name. Title is required.
   * @param bool $save
   *   When FALSE, returns the unsaved entity (handy for builder chains).
   *
   * @return \Drupal\node\Entity\Node
   */
  public function createNode(string $bundle, array $values, bool $save = TRUE): Node {
    $values += [
      'type'        => $bundle,
      'title'       => $values['title'] ?? '',
      'status'      => 1,
      'uid'         => 1,
      'promote'     => 0,
      'sticky'      => 0,
      'langcode'    => \Drupal::languageManager()->getDefaultLanguage()->getId(),
    ];

    $node = Node::create($values);

    if ($save) {
      $node->save();
    }

    return $node;
  }

  /**
   * Creates and places a block instance, mirroring BlockCreationTrait::placeBlock().
   *
   * @param string $plugin_id
   *   Block plugin id (e.g. 'system_powered_by_block', 'views_block:foo-bar').
   * @param array $settings
   *   Optional settings — region, theme, weight, visibility, label.
   *
   * @return \Drupal\block\Entity\Block
   */
  public function placeBlock(string $plugin_id, array $settings = []): Block {
    $config = \Drupal::configFactory();

    $settings += [
      'plugin'     => $plugin_id,
      'region'     => 'content',
      'id'         => strtolower($this->randomMachineName(8)),
      'theme'      => $config->get('system.theme')->get('default'),
      'label'      => $this->randomMachineName(8),
      'visibility' => [],
      'weight'     => 0,
    ];

    $values = [];
    foreach (['region', 'id', 'theme', 'plugin', 'weight', 'visibility'] as $key) {
      $values[$key] = $settings[$key];
      unset($settings[$key]);
    }

    // Visibility conditions carry their condition id under the array key.
    foreach ($values['visibility'] as $id => $visibility) {
      $values['visibility'][$id]['id'] = $id;
    }

    $values['settings'] = $settings;
    $block = Block::create($values);
    $block->save();

    return $block;
  }

  /**
   * Sets a single config value, saving immediately.
   *
   * @param string $name
   *   Config object name, e.g. 'system.site'.
   * @param string|array $key
   *   Either a scalar key or a dot-separated key.
   * @param mixed $value
   *   The value to set.
   */
  public function setConfig(string $name, string|array $key, mixed $value): void {
    $config = \Drupal::configFactory()->getEditable($name);
    $config->set($key, $value)->save();
  }

  /**
   * Wraps a Drush-style status message. Uses messenger() when the container
   * is available; silently no-ops otherwise so the helper can be called from
   * contexts (Drush bootstrap mid-init, PHPUnit) where the container is
   * not yet available.
   */
  public function log(string $message, string $type = 'status'): void {
    if (!\Drupal::hasService('messenger')) {
      return;
    }
    try {
      \Drupal::messenger()->addMessage($message, $type);
    }
    catch (\Throwable) {
      // Container not initialised yet — drop the message silently.
    }
  }

  /**
   * Drupal-8-safe machine name generator. Mirrors core's TestBase::randomMachineName().
   */
  public function randomMachineName(int $length = 8): string {
    $chars = 'abcdefghijklmnopqrstuvwxyz_';
    $out = '';
    $max = strlen($chars) - 1;
    for ($i = 0; $i < $length; $i++) {
      $out .= $chars[random_int(0, $max)];
    }
    return $out;
  }

  /**
   * Wraps an entity save with logging — handy inside loops.
   */
  public function save(EntityInterface $entity, ?string $label = NULL): EntityInterface {
    $entity->save();
    $label ??= $entity->label() ?? $entity->id();
    $this->log(sprintf('Saved %s %s (id=%s).', $entity->getEntityTypeId(), $label, $entity->id()));
    return $entity;
  }

}