namespace Nuxed\Http\Router\Matcher\Resolver;

use namespace Nuxed\Http\Router;

final class PrefixMapOrRoute {
  public function __construct(
    private ?PrefixMap $map,
    private ?Router\Route $route,
  ) {
    invariant(
      ($map === null) !== ($route === null),
      'Must specify map *or* route',
    );
  }

  public function isMap(): bool {
    return $this->map !== null;
  }

  public function isRoute(): bool {
    return $this->route !== null;
  }

  public function getMap(): PrefixMap {
    $map = $this->map;
    invariant($map !== null, 'Called getMap() when !isMap()');
    return $map;
  }

  public function getRoute(): Router\Route {
    $route = $this->route;
    invariant($route !== null, 'Called getRoute() when !isRoute');
    return $route;
  }
}
