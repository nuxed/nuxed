namespace Nuxed\Http\Router;

use namespace HH\Lib\{C, Dict, Str, Vec};

final class RouteCollection {
  private dict<string, Route> $routes = dict[];
  private dict<string, int> $priorities = dict[];

  public function count(): int {
    return C\count($this->routes);
  }

  public function add(string $name, Route $route, int $priority = 0): this {
    $this->remove($name);

    $this->routes[$name] = $route;
    $this->priorities[$name] = $priority;

    return $this;
  }

  public function all(): KeyedContainer<string, Route> {
    $routes = $this->routes;
    $priorities = $this->priorities;
    $names = Vec\keys($routes);
    $keysOrder = Dict\flip($names);
    $routes = Dict\sort_by_key(
      $this->routes,
      ($n1, $n2) ==> (($priorities[$n2] ?? 0) <=> ($priorities[$n1] ?? 0)) ?:
        ($keysOrder[$n1] <=> $keysOrder[$n2]),
    );

    return $routes;
  }

  /**
   * Get a route by name.
   */
  public function get(string $name): ?Route {
    return $this->routes[$name] ?? null;
  }

  /**
   * Removes a route or set of routes by name from the collection.
   */
  public function remove(string ...$names): this {
    $this->routes = Dict\filter_keys(
      $this->routes,
      $name ==> !C\contains_key($names, $name),
    );

    $this->priorities = Dict\filter_keys(
      $this->priorities,
      $name ==> !C\contains_key($names, $name),
    );

    return $this;
  }

  public function addCollection(RouteCollection $collection): this {
    // we need to remove all routes with the same names first because just replacing them
    // would not place the new route at the end of the merged container
    foreach ($collection->all() as $name => $route) {
      $this->remove($name);

      $this->routes[$name] = $route;
      $this->priorities[$name] = $collection->priorities[$name];
    }

    return $this;
  }


  /**
   * Adds a prefix to the path of all child routes.
   */
  public function addPrefix(string $prefix): this {
    $prefix = Str\trim(Str\trim($prefix), '/');

    if ('' === $prefix) {
      return $this;
    }

    foreach ($this->routes as $route) {
      $route->setPath('/'.$prefix.$route->getPath());
    }

    return $this;
  }

  /**
   * Adds a prefix to the name of all the routes within in the collection.
   */
  public function addNamePrefix(string $prefix): this {
    $prefixedRoutes = dict[];
    $prefixedPriorities = dict[];

    foreach ($this->routes as $name => $route) {
      $prefixedRoutes[$prefix.$name] = $route;
      $prefixedPriorities[$prefix.$name] = $this->priorities[$name];
    }

    $this->routes = $prefixedRoutes;
    $this->priorities = $prefixedPriorities;

    return $this;
  }

  /**
   * Sets the host pattern on all routes.
   */
  public function setHost(?string $pattern): this {
    foreach ($this->routes as $route) {
      $route->setHost($pattern);
    }

    return $this;
  }

  /**
   * Adds parameters to all routes.
   *
   * An existing option value under the same name in a route will be overridden.
   */
  public function addParameters(
    KeyedContainer<string, arraykey> $options,
  ): this {
    foreach ($this->routes as $route) {
      $route->addParameters($options);
    }

    return $this;
  }

  /**
   * Sets the schemes (e.g. 'https') all child routes are restricted to.
   *
   * A null value means that any scheme is allowed.
   */
  public function setSchemes(?Container<string> $schemes): this {
    foreach ($this->routes as $route) {
      $route->setSchemes($schemes);
    }

    return $this;
  }

  /**
   * Sets the HTTP methods (e.g. 'POST') all child routes are restricted to.
   *
   * A null value means that any method is allowed.
   */
  public function setMethods(?Container<string> $methods): this {
    foreach ($this->routes as $route) {
      $route->setMethods($methods);
    }

    return $this;
  }
}
