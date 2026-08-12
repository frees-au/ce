<?php

declare(strict_types=1);

namespace Drupal\fs\Controller;

/**
 * Redirects /home-route to the actual homepage (/node/4) with a 301.
 */
final class HomeRouteController {

  /**
   * Redirects to /node/4 with HTTP 301.
   *
   * @return \Symfony\Component\HttpFoundation\RedirectResponse
   *   A 301 redirect to the configured front-page node.
   */
  public function __invoke(): \Symfony\Component\HttpFoundation\RedirectResponse {
    $target = \Drupal::configFactory()
      ->get('system.site')
      ->get('page.front') ?: '/node/4';
    // If the configured front page is somehow this same route, force /node/4.
    if ($target === '/home-route') {
      $target = '/node/4';
    }
    return new \Symfony\Component\HttpFoundation\RedirectResponse(
      $target,
      \Symfony\Component\HttpFoundation\Response::HTTP_MOVED_PERMANENTLY
    );
  }

}
