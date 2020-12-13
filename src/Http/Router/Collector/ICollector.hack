namespace Nuxed\Http\Router\Collector;

use namespace Nuxed\Http\Router;

interface ICollector {
  /**
   * Collecte the route collection.
   */
  public function collect(): Awaitable<Router\RouteCollection>;
}
