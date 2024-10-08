<?php

namespace Drupal\fs\Controller;

/**
 * @file
 * Handles home page shizzle.
 */

use Drupal\Core\Controller\ControllerBase;
use Drupal\Core\Url;
use Symfony\Component\HttpFoundation\RedirectResponse;

/**
 * A test controller.
 */
class HomePageController extends ControllerBase {

  /**
   * Redirect the home page to /ce (well, whichever alias set on $node_uuid).
   *
   * @param string $node_uuid
   *   A node UUID to redirect to, which should be one exported in fs_content.info.yml.
   *
   * @return \Symfony\Component\HttpFoundation\RedirectResponse
   *   A redirect to the page to use instead of the home page.
   */
  public function redirectThatSauce(string $node_uuid) {
    $nodes = $this->entityTypeManager()->getStorage('node')->loadByProperties(['uuid' => $node_uuid]);
    if (count($nodes) === 0) {
      throw new \Exception('Node route UUID doesn\'t appear to match any nodes: ' . $node_uuid);
    }
    $redirect_url = Url::fromRoute('entity.node.canonical', ['node' => reset($nodes)->id()]);
    return new RedirectResponse($redirect_url->toString());
  }

}
