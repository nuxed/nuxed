namespace Nuxed\Http\Router;

use namespace Nuxed\Http\Message;

final class Router implements Generator\IUriGenerator, Matcher\IRequestMatcher {
  private ?Matcher\IRequestMatcher $matcher = null;
  private ?Generator\IUriGenerator $generator = null;
  private ?RouteCollection $collection = null;

  public function __construct(private Collector\ICollector $collector) {}

  /**
   * Match a request against the known routes.
   */
  public async function match(Message\IRequest $request): Awaitable<Route> {
    $matcher = await $this->getMatcher();

    return await $matcher->match($request);
  }

  /**
   * Generate a URI from the named route.
   *
   * Takes the named route and any substitutions, and attempts to generate a
   * URI from it.
   *
   * The URI generated MUST NOT be escaped. If you wish to escape any part of
   * the URI, this should be performed afterwards;
   */
  public async function generate(
    string $route,
    KeyedContainer<string, arraykey> $substitutions = dict[],
  ): Awaitable<Message\IUri> {
    $generator = await $this->getGenerator();

    return await $generator->generate($route, $substitutions);
  }

  public async function getCollection(): Awaitable<RouteCollection> {
    if ($this->collection is null) {
      $this->collection = await $this->collector->collect();
    }

    return $this->collection;
  }

  private async function getMatcher(): Awaitable<Matcher\IRequestMatcher> {
    if ($this->matcher is nonnull) {
      return $this->matcher;
    }

    $collection = await $this->getCollection();
    $resolver = new Matcher\Resolver\Resolver($collection);
    $this->matcher = new Matcher\RequestMatcher($resolver);

    return $this->matcher;
  }

  private async function getGenerator(): Awaitable<Generator\IUriGenerator> {
    if ($this->generator is nonnull) {
      return $this->generator;
    }

    $collection = await $this->getCollection();
    $this->generator = new Generator\UriGenerator($collection);

    return $this->generator;
  }
}
