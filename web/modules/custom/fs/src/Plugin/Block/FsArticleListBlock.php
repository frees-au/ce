<?php

declare(strict_types=1);

namespace Drupal\fs\Plugin\Block;

use Drupal\Component\Utility\Html;
use Drupal\Core\Block\Attribute\Block;
use Drupal\Core\Block\BlockBase;
use Drupal\Core\StringTranslation\TranslatableMarkup;

/**
 * Provides a block to display 'Article List'.
 */
#[Block(
  id: "fs_article_list",
  admin_label: new TranslatableMarkup("Article list app"),
)]
class FsArticleListBlock extends BlockBase {

  /**
   * {@inheritdoc}
   */
  public function build() {
    $build = [];

    $app_id = Html::getUniqueId('article-list');

    $build = [
      '#attached' => [
        'library' => [
          'fs/article-list-app',
        ],
      ],
      '#type' => 'inline_template',
      '#template' => '<div class="article-list" data-article-list-app-id="{{ app_id }}"></div>',
      '#context' => [
        'app_id' => $app_id,
      ],
    ];

    return $build;
  }

}
