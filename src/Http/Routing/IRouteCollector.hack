namespace Nuxed\Http\Routing;

use namespace Nuxed\Http\Message;
use namespace Nuxed\Http\Handler;

interface IRouteCollector {
  public function get(
    string $name,
    string $path,
    Handler\IHandler $handler,
    int $priority = 0,
  ): this;

  public function head(
    string $name,
    string $path,
    Handler\IHandler $handler,
    int $priority = 0,
  ): this;

  public function post(
    string $name,
    string $path,
    Handler\IHandler $handler,
    int $priority = 0,
  ): this;

  public function put(
    string $name,
    string $path,
    Handler\IHandler $handler,
    int $priority = 0,
  ): this;

  public function patch(
    string $name,
    string $path,
    Handler\IHandler $handler,
    int $priority = 0,
  ): this;

  public function delete(
    string $name,
    string $path,
    Handler\IHandler $handler,
    int $priority = 0,
  ): this;

  public function addRoute(Route $route): this;

  public function addRouteCollection(RouteCollection $collection): this;
}
