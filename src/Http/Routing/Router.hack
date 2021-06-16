namespace Nuxed\Http\Routing;

use namespace Nuxed\Http\Message;
use namespace Nuxed\Cache;

final class Router implements IRouter {
  use RouterConvenienceMethodsTrait;

  private RouteCollection $collection;
  private Matcher\IMatcher $matcher;

  public function __construct(?Cache\ICache $cache = null) {
    $this->collection = new RouteCollection();
    $this->matcher = new Matcher\Matcher($this->collection, $cache);
  }

  public function addRoute(Route $route): this {
    $this->collection->add($route);

    return $this;
  }

  public function addRouteCollection(RouteCollection $collection): this {
    $this->collection->addCollection($collection);

    return $this;
  }

  /**
   * Match a request against the known routes.
   */
  public async function match(
    Message\IRequest $request,
  ): Awaitable<(Route, KeyedContainer<string, string>)> {
    return await $this->matcher->match($request);
  }
}
