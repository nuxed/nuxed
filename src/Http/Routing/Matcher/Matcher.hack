namespace Nuxed\Http\Routing\Matcher;

use namespace HH\Lib\{C, Dict, Vec};
use namespace Nuxed\Cache;
use namespace Nuxed\Http\{Exception, Message, Routing};
use Facebook\HackRouter;

final class Matcher implements IMatcher {
  private ?HackRouter\PrefixMatchingResolver<string> $resolver = null;
  private ?Routing\_Private\PrefixMapCollection $collection = null;

  private Cache\ICache $cache;

  public function __construct(
    private Routing\RouteCollection $routes,
    ?Cache\ICache $cache = null,
  ) {
    $this->cache = $cache ?? new Cache\Cache(new Cache\Store\NullStore());
  }

  /**
   * Match a request against the known routes.
   */
  public async function match(
    Message\IRequest $request,
  ): Awaitable<(Routing\Route, KeyedContainer<string, string>)> {
    $method = HackRouter\HttpMethod::assert($request->getMethod());
    $path = $request->getUri()->getPath();

    $resolver = await $this->getResolver();
    try {
      list($route_name, $data) = $resolver->resolve($method, $path);

      return tuple(
        $this->routes->get($route_name),
        Dict\map($data, $value ==> \urldecode($value)),
      );
    } catch (HackRouter\NotFoundException $e) {
      $allowed = await $this->getAllowedMethods($path);
      if (C\is_empty($allowed)) {
        throw new Exception\NotFoundException();
      }

      throw new Exception\MethodNotAllowedException(
        keyset(
          Vec\map(
            $allowed,
            ($hack_router_method) ==>
              Message\HttpMethod::assert((string)$hack_router_method),
          ),
        ),
      );
    }
  }

  <<__Memoize>>
  private async function getAllowedMethods(
    string $path,
  ): Awaitable<keyset<HackRouter\HttpMethod>> {
    $allowed = keyset[];
    $resolver = await $this->getResolver();
    $collection = await $this->getPrefixMapCollection();
    // look into only used methods.
    foreach ($collection->getAllowedMethods() as $method) {
      try {
        $method = HackRouter\HttpMethod::assert((string)$method);
        list($_responder, $_data) = $resolver->resolve($method, $path);
        $allowed[] = $method;
      } catch (HackRouter\NotFoundException $_) {
        continue;
      }
    }

    return $allowed;
  }

  private async function getPrefixMapCollection(
  ): Awaitable<Routing\_Private\PrefixMapCollection> {
    if (null !== $this->collection) {
      return $this->collection;
    }

    $this->collection = await $this->cache
      ->remember<Routing\_Private\PrefixMapCollection>(
        __FILE__,
        async () ==> Routing\_Private\PrefixMapCollection::fromRouteCollection(
          $this->routes,
        ),
      );

    return $this->collection;
  }

  private async function getResolver(
  ): Awaitable<HackRouter\PrefixMatchingResolver<string>> {
    if ($this->resolver !== null) {
      return $this->resolver;
    }

    $routes = await $this->getPrefixMapCollection() |> $$->getMap();

    $this->resolver = new HackRouter\PrefixMatchingResolver($routes);
    return $this->resolver;
  }
}
