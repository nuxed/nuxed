namespace Nuxed\Http\Routing;

use namespace HH\Lib\{C, Dict, Vec};

final class RouteCollection {
  private dict<string, Route> $routes = dict[];

  /**
   * Create a route-collection.
   */
  public static function create(): this {
    return new self();
  }

  public function count(): int {
    return C\count($this->routes);
  }

  /**
   * Add a route to the collection.
   */
  public function add(Route $route): this {
    $name = $route->getName();

    // we need to remove any route with the same name first because just replacing it
    // would not place the new route at the end of the dict!
    $this->remove($name);

    $this->routes[$name] = $route;

    return $this;
  }

  /**
   * Return all routes within this collection.
   */
  public function all(): KeyedContainer<string, Route> {
    $routes = $this->routes;
    $keysOrder = Dict\flip(Vec\keys($routes));

    $routes = Dict\sort(
      $this->routes,
      ($route1, $route2) ==> (
        $route2->getPriority() <=> $route1->getPriority()
      ) ?:
        ($keysOrder[$route1->getName()] <=> $keysOrder[$route2->getName()]),
    );

    return $routes;
  }

  /**
   * Get a route by name.
   */
  public function get(string $name): Route {
    $route = $this->routes[$name] ?? null;

    invariant(
      $route !== null,
      'Route "%s" does not exist within the collection.',
      $name,
    );

    return $route;
  }

  /**
   * Removes a route or set of routes by name from the collection.
   */
  public function remove(string ...$names): this {
    foreach ($names as $name) {
      unset($this->routes[$name]);
    }

    return $this;
  }

  public function addCollection(RouteCollection $collection): this {
    foreach ($collection->all() as $route) {
      $this->add($route);
    }

    return $this;
  }
}
