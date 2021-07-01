/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http\Routing\_Private;

use namespace HH\Lib\{Dict, Vec};
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
