namespace Nuxed\Http\Router\Matcher\Resolver;

use type Facebook\HackRouter\PatternParser\{
  LiteralNode,
  Node,
  ParameterNode,
  Parser,
};
use namespace HH\Lib\{C, Dict, Keyset, Math, Str, Vec};
use namespace Nuxed\Http\Router;

final class PrefixMap {
  public function __construct(
    private dict<string, Router\Route> $literals,
    private dict<string, PrefixMap> $prefixes,
    private dict<string, PrefixMapOrRoute> $regexps,
  ) {}

  public function getLiterals(): dict<string, Router\Route> {
    return $this->literals;
  }

  public function getPrefixes(): dict<string, PrefixMap> {
    return $this->prefixes;
  }

  public function getRegexps(): dict<string, PrefixMapOrRoute> {
    return $this->regexps;
  }

  public static function fromFlatMap(
    dict<string, Router\Route> $map,
  ): PrefixMap {
    $entries = Vec\map_with_key(
      $map,
      ($pattern, $route) ==>
        tuple(Parser::parse($pattern)->getChildren(), $route),
    );

    return self::fromFlatMapImpl($entries);
  }

  private static function fromFlatMapImpl(
    vec<(vec<Node>, Router\Route)> $entries,
  ): PrefixMap {
    $literals = dict[];
    $prefixes = vec[];
    $regexps = vec[];
    foreach ($entries as list($nodes, $route)) {
      if (C\is_empty($nodes)) {
        $literals[''] = $route;
        continue;
      }
      $node = C\firstx($nodes);
      $nodes = Vec\drop($nodes, 1);
      if ($node is LiteralNode) {
        if (C\is_empty($nodes)) {
          $literals[$node->getText()] = $route;
        } else {
          $prefixes[] = tuple($node->getText(), $nodes, $route);
        }
        continue;
      }

      if ($node is ParameterNode && $node->getRegexp() === null) {
        $next = C\first($nodes);
        if ($next is LiteralNode && Str\starts_with($next->getText(), '/')) {
          $regexps[] = tuple($node->asRegexp('#'), $nodes, $route);
          continue;
        }
      }
      $regexps[] = tuple(
        Vec\concat(vec[$node], $nodes)
          |> Vec\map($$, $n ==> $n->asRegexp('#'))
          |> Str\join($$, ''),
        vec[],
        $route,
      );
    }

    $by_first = Dict\group_by($prefixes, $entry ==> $entry[0]);
    $grouped = self::groupByCommonPrefix(Keyset\keys($by_first));
    $prefixes = Dict\map_with_key(
      $grouped,
      ($prefix, $keys) ==> Vec\map(
        $keys,
        $key ==> Vec\map(
          $by_first[$key],
          $row ==> {
            list($text, $nodes, $route) = $row;
            if ($text === $prefix) {
              return tuple($nodes, $route);
            }
            $suffix = Str\strip_prefix($text, $prefix);
            return tuple(
              Vec\concat(vec[new LiteralNode($suffix)], $nodes),
              $route,
            );
          },
        ),
      )
        |> Vec\flatten($$)
        |> self::fromFlatMapImpl($$),
    );

    $by_first = Dict\group_by($regexps, $entry ==> $entry[0]);
    $regexps = dict[];
    foreach ($by_first as $first => $entries) {
      if (C\count($entries) === 1) {
        list($_, $nodes, $route) = C\onlyx($entries);
        $rest = Str\join(Vec\map($nodes, $n ==> $n->asRegexp('#')), '');
        $regexps[$first.$rest] = new PrefixMapOrRoute(null, $route);
        continue;
      }
      $regexps[$first] = new PrefixMapOrRoute(
        self::fromFlatMapImpl(Vec\map($entries, $e ==> tuple($e[1], $e[2]))),
        null,
      );
    }

    return new self($literals, $prefixes, $regexps);
  }

  private static function groupByCommonPrefix(
    keyset<string> $keys,
  ): dict<string, keyset<string>> {
    if (C\is_empty($keys)) {
      return dict[];
    }
    $lens = Vec\map($keys, $key ==> Str\length($key));
    $min = Math\min($lens);
    invariant(
      $min is nonnull && $min !== 0,
      "Shouldn't have 0-length prefixes",
    );
    return $keys
      |> Dict\group_by($$, $key ==> Str\slice($key, 0, $min))
      |> Dict\map($$, $vec ==> keyset($vec));
  }
}
