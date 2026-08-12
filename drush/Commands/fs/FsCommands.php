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

  #[Cmd\Command(name: 'fs:create-media', description: 'Create a media entity.')]
  #[Cmd\Argument(name: 'bundle', description: 'Media bundle machine name (e.g. stream, image).')]
  #[Cmd\Argument(name: 'source_field_value', description: 'Value to set on the bundle source field (e.g. a YouTube URL for stream).')]
  public function createMedia(string $bundle, string $source_field_value): void {
    $type = \Drupal::entityTypeManager()->getStorage('media_type')->load($bundle);
    if (!$type) {
      throw new \RuntimeException(sprintf('Unknown media bundle "%s".', $bundle));
    }
    $source_field = $type->get('source_configuration')['source_field'] ?? NULL;
    if (!$source_field) {
      throw new \RuntimeException(sprintf('Media bundle "%s" has no source_field configured.', $bundle));
    }
    $media = $this->helpers()->createMedia($bundle, [
      $source_field => $source_field_value,
    ]);
    $this->logger()->success(sprintf('Created media %d (bundle=%s): %s', $media->id(), $media->bundle(), $media->label() ?? ''));
  }

  #[Cmd\Command(name: 'fs:import-youtube-channel', description: 'Import a list of YouTube videos into media:stream.')]
  #[Cmd\Option(name: 'dry-run', description: 'Print what would be created without touching the DB.')]
  public function importYoutubeChannel(array $options = ['dry-run' => NULL]): void {
    $videos = self::FREETHE_SAUCE_VIDEOS;
    $dry = !empty($options['dry-run']);
    $created = 0;
    $failed = [];
    foreach ($videos as $title => $url) {
      try {
        if ($dry) {
          $this->logger()->notice(sprintf('[dry-run] would create stream: %s -> %s', $title, $url));
          $created++;
          continue;
        }
        $media = $this->helpers()->createMedia('stream', [
          'name'              => $title,
          'media_oembed_video' => $url,
        ]);
        $this->logger()->success(sprintf('Created media %d: %s', $media->id(), $title));
        $created++;
      }
      catch (\Throwable $e) {
        $failed[] = ['title' => $title, 'url' => $url, 'error' => $e->getMessage()];
      }
    }
    $this->logger()->success(sprintf('Imported %d YouTube videos into media:stream%s.', $created, $dry ? ' (dry-run)' : ''));
    if ($failed) {
      $this->logger()->warning(sprintf('%d videos failed:', count($failed)));
      foreach ($failed as $f) {
        $this->logger()->warning(sprintf('  - %s (%s): %s', $f['title'], $f['url'], $f['error']));
      }
    }
  }

  #[Cmd\Command(name: 'fs:create-articles-for-channel', description: 'Create one article node per media:stream in the channel import.')]
  #[Cmd\Option(name: 'dry-run', description: 'Print what would be created without touching the DB.')]
  public function createArticlesForChannel(array $options = ['dry-run' => NULL]): void {
    $dry = !empty($options['dry-run']);
    $q = \Drupal::entityTypeManager()->getStorage('media')->getQuery()
      ->condition('bundle', 'stream')
      ->accessCheck(FALSE);
    $ids = $q->execute();
    if (!$ids) {
      $this->logger()->warning('No media:stream entities found — run fs:import-youtube-channel first.');
      return;
    }
    $media_storage = \Drupal::entityTypeManager()->getStorage('media');
    $created = 0;
    $failed = [];
    foreach ($ids as $mid) {
      $m = $media_storage->load($mid);
      $title = $m->label();
      $url = $m->get('media_oembed_video')->value ?? '';
      if (!$title || !$url) {
        $failed[] = ['mid' => $mid, 'error' => 'missing title or URL on media'];
        continue;
      }
      if ($dry) {
        $this->logger()->notice(sprintf('[dry-run] would create article "%s" linked to media %d', $title, $mid));
        $created++;
        continue;
      }
      try {
        // Reuse title verbatim; lead is a one-liner; markup has the watch URL.
        $node = $this->helpers()->createNode('article', [
          'title'  => $title,
          'lead'   => ['value' => 'Free Sauce tutorial.', 'format' => 'basic'],
          'markup' => [
            'value'  => sprintf('<p>Watch on YouTube: <a href="%s">%s</a></p>', htmlspecialchars($url, ENT_QUOTES), htmlspecialchars($title, ENT_QUOTES)),
            'format' => 'safe_html',
          ],
          'youtube' => $mid,
          'status'  => 1,
        ]);
        $this->logger()->success(sprintf('Created article %d: %s (media %d)', $node->id(), $title, $mid));
        $created++;
      }
      catch (\Throwable $e) {
        $failed[] = ['title' => $title, 'error' => $e->getMessage()];
      }
    }
    $this->logger()->success(sprintf('Created %d article nodes%s.', $created, $dry ? ' (dry-run)' : ''));
    if ($failed) {
      $this->logger()->warning(sprintf('%d articles failed:', count($failed)));
      foreach ($failed as $f) {
        $this->logger()->warning(sprintf('  - %s: %s', $f['title'] ?? $f['mid'], $f['error']));
      }
    }
  }

  /**
   * Curated list of @FreeTheSauce videos on youtube.com/@freethesauce.
   *
   * Sourced from the public channel /videos tab on 2026-08-12. 21 of the
   * 25 visible channel videos are mapped here — the remaining 4 were not
   * reachable via the public scrape (likely unlisted or shorts); add them
   * by hand once Si confirms.
   *
   * @var array<string,string>
   */
  private const FREETHE_SAUCE_VIDEOS = [
    'Brogue - Conjuration - D21 in 2:35'                                      => 'https://www.youtube.com/watch?v=sztrGA3vT5g',
    'Brogue - Broadsword, Reflection to D14'                                  => 'https://www.youtube.com/watch?v=PJz-mqcugh0',
    'Talking PHPStan with Matt Glaman'                                        => 'https://www.youtube.com/watch?v=zsRF3Lb6L38',
    'Setting up the DDEV plugin, tyler36/ddev-xhgui'                          => 'https://www.youtube.com/watch?v=Knrhfwbop2w',
    'Local starshot dev - project_browser'                                    => 'https://www.youtube.com/watch?v=MlbjSiDEzP4',
    'Drupal modules that provide "repeating field groups"'                    => 'https://www.youtube.com/watch?v=ZorUUuC8oxc',
    'Add your first Drupal gitlab-ci.yml thru the web UI'                     => 'https://www.youtube.com/watch?v=m8-Rh5ognXk',
    "Time to config:export 'field_' to pasture"                               => 'https://www.youtube.com/watch?v=2495KafRZAg',
    'Xdebug with VS Code'                                                     => 'https://www.youtube.com/watch?v=coLqZ3Ogg7U',
    'Reviewing our website codebase, which was open sourced.'                => 'https://www.youtube.com/watch?v=qUJpx5w0avM',
    'Run Drupal core tests in 7mins'                                          => 'https://www.youtube.com/watch?v=l0dl2NQsDnI',
    'Adding PHPStan to a Drupal project'                                      => 'https://www.youtube.com/watch?v=8al0GVuYwYY',
    'BONUS: Docker Compose following the Docker4Drupal setup'                 => 'https://www.youtube.com/watch?v=wihnEBTKGQc',
    'Adding DDEV and installing Drupal (again)'                               => 'https://www.youtube.com/watch?v=aqEhYOWaxZc',
    'Adding Lando and installing Drupal'                                      => 'https://www.youtube.com/watch?v=nVldMlh1AUg',
    'Building out an initial Drupal composer.ison'                            => 'https://www.youtube.com/watch?v=6XHy3cJv4Ho',
    'Deciding a structure for sites/default/settings'                         => 'https://www.youtube.com/watch?v=hYEK35tBdmY',
    'Drupal 10+ project setup - an introduction'                             => 'https://www.youtube.com/watch?v=uToDLeRRLxY',
    'Adding caching around GAS calls to Airtable'                             => 'https://www.youtube.com/watch?v=buGoIh3h1g0',
    'Store a Google Apps Script in Git with Clasp'                            => 'https://www.youtube.com/watch?v=ds5LAIWku-E',
    'Manually load some Airtable data from your Google Apps Script'           => 'https://www.youtube.com/watch?v=6bT8GU2ZwAs',
  ];

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