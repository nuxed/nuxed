namespace Nuxed\Http\Router\Collector;

use namespace HH\Asio;
use namespace Nuxed\Http\Router;

final class ChainCollector implements ICollector {
  public function __construct(private Container<ICollector> $collectors) {}

  public async function collect(): Awaitable<Router\RouteCollection> {
    $collections = vec[];
    foreach ($this->collectors as $collector) {
      $collections[] = $collector->collect();
    }

    $mainCollection = new Router\RouteCollection();
    $collections = await Asio\v($collections);
    foreach ($collections as $collection) {
      $mainCollection->addCollection($collection);
    }

    return $mainCollection;
  }
}
