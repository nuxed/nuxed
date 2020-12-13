namespace Nuxed\Http\Router\Collector;

use namespace Nuxed\Http\Router;
use namespace Nuxed\Http\Router\Attribute;
use namespace Nuxed\Http\Server\Handler;

final class HandlerCollector implements ICollector {
  public function __construct(
    private Container<classname<Handler\IHandler>> $handlers = vec[],
  ) {}

  public async function collect(): Awaitable<Router\RouteCollection> {
    $collection = new Router\RouteCollection();
    foreach ($this->handlers as $handler) {
      $route = (new \ReflectionClass($handler))->getAttributeClass(
        Attribute\Route::class,
      );

      if ($route is nonnull) {
        $collection->add(
          $route->getName(),
          new Router\Route(
            $route->getPath(),
            $handler,
            $route->getMethods(),
            $route->getHost(),
            $route->getSchemes(),
            $route->getParameters(),
          ),
          $route->getPriority() ?? 1,
        );
      }
    }

    return $collection;
  }
}
