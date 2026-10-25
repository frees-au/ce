<?php

declare(strict_types=1);

namespace Drupal\fs\Controller;

use Drupal\Core\Config\ConfigFactoryInterface;
use Drupal\Core\DependencyInjection\ContainerInjectionInterface;
use Symfony\Component\DependencyInjection\ContainerInterface;
use Symfony\Component\HttpFoundation\RedirectResponse;
use Symfony\Component\HttpFoundation\Response;

/**
 * Redirects /home-route to the actual homepage (/node/4) with a 301.
 */
final class HomeRouteController implements ContainerInjectionInterface {

  public function __construct(
    private readonly ConfigFactoryInterface $configFactory,
  ) {}

  /**
   * {@inheritdoc}
   */
  public static function create(ContainerInterface $container): self {
    return new self($container->get('config.factory'));
  }

  /**
   * Redirects to /node/4 with HTTP 301.
   *
   * @return \Symfony\Component\HttpFoundation\RedirectResponse
   *   A 301 redirect to the configured front-page node.
   */
  public function __invoke(): RedirectResponse {
    $configuredTarget = $this->configFactory
      ->get('system.site')
      ->get('page.front');
    $target = is_string($configuredTarget) && $configuredTarget !== ''
      ? $configuredTarget
      : '/node/4';
    // If the configured front page is somehow this same route, force /node/4.
    if ($target === '/home-route') {
      $target = '/node/4';
    }
    return new RedirectResponse(
      $target,
      Response::HTTP_MOVED_PERMANENTLY
    );
  }

}
