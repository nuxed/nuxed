namespace Nuxed\Http\Router\Generator;

use namespace HH\Lib\{C, Str, Vec};
use namespace Nuxed\Http\{Message, Router};
use namespace Facebook\HackRouter;
use namespace Facebook\HackRouter\PatternParser;

final class UriGenerator implements IUriGenerator {
  public function __construct(private Router\RouteCollection $collection) {}

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
    string $name,
    KeyedContainer<string, arraykey> $substitutions = dict[],
  ): Awaitable<Message\Uri> {
    $route = $this->collection->get($name);
    if ($route is null) {
      $message = Str\format('Route "%s" doesn\'t exist', $name);
      $alternatives = Router\_Private\alternatives(
        $name,
        Vec\keys($this->collection->all()),
      );
      if (0 !== C\count($alternatives)) {
        $message .= Str\format(', did you mean %s.', Str\join(
          Vec\map(
            $alternatives,
            ($alternative) ==> Str\format('"%s"', $alternative),
          ),
          ', ',
        ));
      } else {
        $message .= '.';
      }

      throw new Router\Exception\InvalidArgumentException($message);
    }

    try {
      $nodes = PatternParser\Parser::parse($route->getPath());
      $parts = vec[];
      foreach ($nodes->getChildren() as $node) {
        $parts = Vec\concat(
          $parts,
          $this->getUriPatternParts($node, $substitutions),
        );
      }

      $uriBuilder = new HackRouter\UriBuilder($parts);
      foreach ($substitutions as $key => $value) {
        if ($value is int) {
          $uriBuilder->setInt($key, $value);
        } else if ($value is string) {
          $uriBuilder->setString($key, $value);
        }
      }

      return new Message\Uri($uriBuilder->getPath());
    } catch (\Exception $e) {
      if (!$e is Router\Exception\IException) {
        $e = new Router\Exception\RuntimeException(
          $e->getMessage(),
          $e->getCode(),
          $e,
        );
      }

      throw $e;
    }
  }

  private function getUriPatternParts(
    PatternParser\Node $node,
    KeyedContainer<string, arraykey> $substitutions = dict[],
    bool $optional = false,
  ): vec<HackRouter\UriPatternPart> {
    $parts = vec[];
    if ($node is PatternParser\LiteralNode) {
      $parts[] = new HackRouter\UriPatternLiteral($node->getText());
    } else if ($node is PatternParser\ParameterNode) {
      if (!C\contains_key($substitutions, $node->getName())) {
        if ($optional) {
          return $parts;
        }

        throw new Router\Exception\InvalidArgumentException(
          Str\format('Missing parameter %s', $node->getName()),
        );
      }
      $value = $substitutions[$node->getName()];
      if ($value is string) {
        $part = new HackRouter\StringRequestParameter(
          $node->getRegexp() === '.+'
            ? HackRouter\StringRequestParameterSlashes::ALLOW_SLASHES
            : HackRouter\StringRequestParameterSlashes::WITHOUT_SLASHES,
          $node->getName(),
        );
        $part->assert($value);

        $parts[] = $part;
      } else if ($value is int) {
        $parts[] = new HackRouter\IntRequestParameter($node->getName());
      }
    } else if ($node is PatternParser\OptionalNode) {
      $pattern = $node->getPattern();
      $children = $pattern->getChildren();
      foreach ($children as $child) {
        $parts = Vec\concat(
          $parts,
          $this->getUriPatternParts($child, $substitutions, true),
        );
      }
    }

    return $parts;
  }
}
