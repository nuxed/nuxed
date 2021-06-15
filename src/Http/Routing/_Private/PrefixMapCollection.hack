namespace Nuxed\Http\Routing\_Private;

use namespace HH\Lib\{Dict, Str, Vec};
use namespace Facebook\HackRouter;
use namespace Nuxed\Http\{Message, Routing};

final class PrefixMapCollection {
  private function __construct(
    private dict<
      HackRouter\HttpMethod,
      HackRouter\PrefixMatching\PrefixMap<string>,
    > $map,
    private vec<Message\HttpMethod> $methods,
  ) {}

  public static function fromRouteCollection(
    Routing\RouteCollection $collection,
  ): PrefixMapCollection {
    $map = dict[];
    $all_methods = vec[];
    foreach ($collection->all() as $route) {
      $name = $route->getName();
      $path = $route->getPath();
      $methods = $route->getMethods();
      $all_methods = Vec\concat($methods, $all_methods);
      $methods = HackRouter\HttpMethod::assertAll($methods);
      foreach ($methods as $method) {
        $map[$method] ??= dict[];
        $map[$method][$path] = $name;
      }
    }

    $res = Dict\map(
      $map,
      $routes ==> HackRouter\PrefixMatching\PrefixMap::fromFlatMap($routes),
    );

    return new self($res, Vec\unique($all_methods));
  }

  public function getMap(
  ): dict<HackRouter\HttpMethod, HackRouter\PrefixMatching\PrefixMap<string>> {
    return $this->map;
  }

  public function getAllowedMethods(): vec<Message\HttpMethod> {
    return $this->methods;
  }
}
