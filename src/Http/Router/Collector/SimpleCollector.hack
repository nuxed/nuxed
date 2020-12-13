namespace Nuxed\Http\Router\Collector;

use namespace Nuxed\Http\{Message, Router};
use namespace Nuxed\Http\Server\Handler;

final class SimpleCollector implements ICollector {
  private Router\RouteCollection $collection;

  public function __construct() {
    $this->collection = new Router\RouteCollection();
  }

  /**
   * Add a route for the route collection.
   */
  public function route(
    string $name,
    string $path,
    classname<Handler\IHandler> $handler,
    ?Container<string> $methods = null,
    ?string $host = null,
    int $priority = 1,
    ?Container<string> $schemes = vec[],
    KeyedContainer<string, arraykey> $parameters = dict[],
  ): Router\Route {
    $route = new Router\Route(
      $path,
      $handler,
      $methods,
      $host,
      $schemes,
      $parameters,
    );

    $this->collection->add($name, $route, $priority);

    return $route;
  }

  public function get(
    string $name,
    string $path,
    classname<Handler\IHandler> $handler,
    ?string $host = null,
    int $priority = 1,
    ?Container<string> $schemes = vec[],
    KeyedContainer<string, arraykey> $parameters = dict[],
  ): Router\Route {
    return $this->route(
      $name,
      $path,
      $handler,
      vec[Message\RequestMethod::GET],
      $host,
      $priority,
      $schemes,
      $parameters,
    );
  }

  public function post(
    string $name,
    string $path,
    classname<Handler\IHandler> $handler,
    ?string $host = null,
    int $priority = 1,
    ?Container<string> $schemes = vec[],
    KeyedContainer<string, arraykey> $parameters = dict[],
  ): Router\Route {
    return $this->route(
      $name,
      $path,
      $handler,
      vec[Message\RequestMethod::POST],
      $host,
      $priority,
      $schemes,
      $parameters,
    );
  }

  public function put(
    string $name,
    string $path,
    classname<Handler\IHandler> $handler,
    ?string $host = null,
    int $priority = 1,
    ?Container<string> $schemes = vec[],
    KeyedContainer<string, arraykey> $parameters = dict[],
  ): Router\Route {
    return $this->route(
      $name,
      $path,
      $handler,
      vec[Message\RequestMethod::PUT],
      $host,
      $priority,
      $schemes,
      $parameters,
    );
  }

  public function patch(
    string $name,
    string $path,
    classname<Handler\IHandler> $handler,
    ?string $host = null,
    int $priority = 1,
    ?Container<string> $schemes = vec[],
    KeyedContainer<string, arraykey> $parameters = dict[],
  ): Router\Route {
    return $this->route(
      $name,
      $path,
      $handler,
      vec[Message\RequestMethod::PATCH],
      $host,
      $priority,
      $schemes,
      $parameters,
    );
  }

  public function delete(
    string $name,
    string $path,
    classname<Handler\IHandler> $handler,
    ?string $host = null,
    int $priority = 1,
    ?Container<string> $schemes = vec[],
    KeyedContainer<string, arraykey> $parameters = dict[],
  ): Router\Route {
    return $this->route(
      $name,
      $path,
      $handler,
      vec[Message\RequestMethod::DELETE],
      $host,
      $priority,
      $schemes,
      $parameters,
    );
  }

  public function any(
    string $name,
    string $path,
    classname<Handler\IHandler> $handler,
    ?string $host = null,
    int $priority = 1,
    ?Container<string> $schemes = vec[],
    KeyedContainer<string, arraykey> $parameters = dict[],
  ): Router\Route {
    return $this->route(
      $name,
      $path,
      $handler,
      null,
      $host,
      $priority,
      $schemes,
      $parameters,
    );
  }

  public async function collect(): Awaitable<Router\RouteCollection> {
    return $this->collection;
  }
}
