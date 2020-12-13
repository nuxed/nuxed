namespace Nuxed\Http\Router\Matcher\Resolver;

use namespace HH\Lib\{C, Dict, Str};
use namespace Nuxed\Http\{Message, Router};

final class Resolver {
  public function __construct(private Router\RouteCollection $collection) {}

  public function resolve(Message\IRequest $request): Router\Route {
    $uri = $request->getUri();
    $collection = $this->collection->all()
      |> Dict\filter($$, (Router\Route $route): bool ==> {
        $schemes = $route->getSchemes();
        if ($schemes is nonnull && !C\contains($schemes, $uri->getScheme())) {
          return false;
        }

        $host = $route->getHost();
        if ($host is nonnull && $host !== $uri->getHost()) {
          return false;
        }

        return true;
      });

    $flatMap = dict[];
    foreach ($collection as $name => $route) {
      $route->setParameter('_route_name', $name);

      $methods = $route->getMethods();
      if ($methods is null) {
        $methods = vec[$request->getMethod()];
      }

      foreach ($methods as $method) {
        $flatMap[$method] ??= dict[];
        $flatMap[$method][$route->getPath()] = $route;
      }
    }

    $flatMap = Dict\map($flatMap, $column ==> PrefixMap::fromFlatMap($column));

    $method = $request->getMethod();
    $map = $flatMap[$method] ?? null;

    if ($map === null) {
      throw new Router\Exception\NotFoundException();
    }

    return $this->resolveWithMap($uri->getPath(), $map);
  }

  public function getAllowedMethods(Message\IRequest $request): ?vec<string> {
    $allowed = vec[];
    foreach (Message\RequestMethod::getValues() as $method) {
      try {
        if ($method === $request->getMethod()) {
          continue;
        }

        $_route = $this->resolve($request->withMethod($method));

        $allowed[] = $method;
      } catch (Router\Exception\NotFoundException $_) {
        continue;
      }
    }

    return $allowed === vec[] ? null : $allowed;
  }

  private function resolveWithMap(string $path, PrefixMap $map): Router\Route {
    $literals = $map->getLiterals();
    if (C\contains_key($literals, $path)) {
      return $literals[$path];
    }

    $prefixes = $map->getPrefixes();
    if (!C\is_empty($prefixes)) {
      $prefix_len = Str\length(C\first_keyx($prefixes));
      $prefix = Str\slice($path, 0, $prefix_len);
      if (C\contains_key($prefixes, $prefix)) {
        return $this->resolveWithMap(
          Str\strip_prefix($path, $prefix),
          $prefixes[$prefix],
        );
      }
    }

    $regexps = $map->getRegexps();
    foreach ($regexps as $regexp => $_sub_map) {
      $pattern = '#^'.$regexp.'#';
      $matches = varray[];

      if (\preg_match_with_matches($pattern, $path, inout $matches) !== 1) {
        continue;
      }

      $matched = $matches[0];
      $remaining = Str\strip_prefix($path, $matched);

      $data = Dict\filter_keys($matches, $key ==> $key is string);
      $sub = $regexps[$regexp];

      if ($sub->isRoute()) {
        if ($remaining === '') {
          $route = $sub->getRoute();
          $route->addParameters($data);

          return $route;
        }

        continue;
      }

      try {
        $route = $this->resolveWithMap($remaining, $sub->getMap());
        $route->addParameters($data);

        return $route;
      } catch (Router\Exception\NotFoundException $_) {
        continue;
      }
    }

    throw new Router\Exception\NotFoundException();
  }
}
