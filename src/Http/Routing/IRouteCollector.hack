namespace Nuxed\Http\Routing;

use namespace Nuxed\Http\Handler;

interface IRouteCollector {
  public function get(
    string $path,
    Handler\IHandler $handler,
    int $priority = 0,
  ): this;

  public function head(
    string $path,
    Handler\IHandler $handler,
    int $priority = 0,
  ): this;

  public function post(
    string $path,
    Handler\IHandler $handler,
    int $priority = 0,
  ): this;

  public function put(
    string $path,
    Handler\IHandler $handler,
    int $priority = 0,
  ): this;

  public function patch(
    string $path,
    Handler\IHandler $handler,
    int $priority = 0,
  ): this;

  public function delete(
    string $path,
    Handler\IHandler $handler,
    int $priority = 0,
  ): this;

  public function addRoute(Route $route): this;

  public function addRouteCollection(RouteCollection $collection): this;
}
