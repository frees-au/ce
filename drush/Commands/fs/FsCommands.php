<?php

declare(strict_types=1);

namespace Drush\Commands\fs;

use Drush\Attributes as Cmd;
use Drush\Attributes\Bootstrap as BootstrapAttr;
use Drush\Boot\DrupalBootLevels;
use Drush\Commands\DrushCommands;

// scripts/includes/ lives outside the Composer autoload map by design
// (it is build-time helper code, not a runtime module). Require it
// explicitly so Drush commands have access to ContentHelpers + the trait.
require_once __DIR__ . '/../../../scripts/includes/ContentHelpers.php';
require_once __DIR__ . '/../../../scripts/includes/ContentHelpersTrait.php';

use FreeSauce\Ce\Scripts\ContentHelpersTrait;

/**
 * Free Sauce / frees.au content scaffolding commands.
 *
 * Loaded automatically by Drush from drush/Commands/fs/. Run with:
 *
 *   ./vendor/bin/drush fs:create-node article "Hello world"
 *   ./vendor/bin/drush fs:place-block system_powered_by_block --region=sidebar_first
 *   ./vendor/bin/drush fs:write-config system.site name "Free Sauce"
 *
 * Use `fs:doctor` to confirm Drupal is bootstrapped and ContentHelpers is
 * reachable before assuming a failure is in your command.
 */
#[BootstrapAttr(level: DrupalBootLevels::FULL)]
final class FsCommands extends DrushCommands {

  use ContentHelpersTrait;

  #[Cmd\Command(name: 'fs:doctor', description: 'Verify Drupal is bootstrapped and ContentHelpers loads.')]
  public function doctor(): void {
    // Reaching this point at all means Drush dispatched the command after
    // a full Drupal bootstrap. Just confirm our helper is reachable.
    $this->helpers()->log('ContentHelpers loaded OK.');
    $this->logger()->success('fs:* command surface is reachable.');
  }

  #[Cmd\Command(name: 'fs:create-node', description: 'Create a node by bundle and title.')]
  #[Cmd\Argument(name: 'bundle', description: 'Node bundle machine name (e.g. article).')]
  #[Cmd\Argument(name: 'title', description: 'Node title.')]
  public function createNode(string $bundle, string $title): void {
    $node = $this->helpers()->createNode($bundle, ['title' => $title]);
    $this->logger()->success(sprintf('Created node %d: %s', $node->id(), $node->label()));
  }

  #[Cmd\Command(name: 'fs:place-block', description: 'Place a block instance in a theme region.')]
  #[Cmd\Argument(name: 'plugin_id', description: 'Block plugin id.')]
  #[Cmd\Option(name: 'region', description: 'Theme region (default content).')]
  #[Cmd\Option(name: 'theme', description: 'Theme machine name (defaults to system.theme default).')]
  public function placeBlock(string $plugin_id, array $options = ['region' => 'content', 'theme' => NULL]): void {
    $settings = ['region' => $options['region']];
    if (!empty($options['theme'])) {
      $settings['theme'] = $options['theme'];
    }
    $block = $this->helpers()->placeBlock($plugin_id, $settings);
    $this->logger()->success(sprintf('Placed block %s in %s.', $block->id(), $options['region']));
  }

  #[Cmd\Command(name: 'fs:write-config', description: 'Set a value in an editable config object.')]
  #[Cmd\Argument(name: 'name', description: 'Config object name (e.g. system.site).')]
  #[Cmd\Argument(name: 'key', description: 'Config key (dot-separated allowed).')]
  #[Cmd\Argument(name: 'value', description: 'Value to set.')]
  public function writeConfig(string $name, string $key, string $value): void {
    $this->helpers()->setConfig($name, $key, $value);
    $this->logger()->success(sprintf('Set %s:%s = %s', $name, $key, $value));
  }

}