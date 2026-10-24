<?php

declare(strict_types=1);

namespace Drupal\fs\Plugin\Block;

use Drupal\Core\Block\BlockBase;

/**
 * Renders the client-side Lunr search UI.
 *
 * The search_api_lunr module is a client-side search engine: PHP writes JSON
 * index files and the browser builds the Lunr index in JavaScript. The results UI is
 * driven by the `search_api_lunr_page` theme, which the contrib module only
 * exposes through its `/js-search/{server}/{index}` route. The contrib
 * `search_api_lunr_form` block is not a substitute: it renders a bare form
 * without the results container that `search.index.js` binds to, so no results
 * are ever displayed.
 *
 * Rendering the theme directly gives a block that can be placed on a single
 * page, and keeps the search UI off every other page.
 *
 * @Block(
 *   id = "fs_search",
 *   admin_label = @Translation("Search"),
 * )
 */
final class SearchBlock extends BlockBase {

  /**
   * The Search API server that holds the content index.
   */
  protected const SERVER_ID = 'lunr';

  /**
   * The Search API index to search.
   */
  protected const INDEX_ID = 'content';

  /**
   * {@inheritdoc}
   *
   * @return array<string, mixed>
   *   A render array using the contrib `search_api_lunr_page` theme.
   */
  public function build(): array {
    return [
      '#theme' => 'search_api_lunr_page',
      // The theme interpolates these straight into data attributes, so they
      // must be the plain server and index IDs.
      '#server' => self::SERVER_ID,
      '#index' => self::INDEX_ID,
      '#attached' => [
        'library' => [
          'search_api_lunr/search',
        ],
      ],
    ];
  }

}
