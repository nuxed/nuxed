namespace Nuxed\Http\Router\Attribute;

use namespace HH;
use namespace HH\Lib\{Str, Vec};

final class Route implements HH\ClassAttribute {
  public function __construct(
    private string $name,
    private string $path,
    private ?Container<string> $methods = null,
    private ?string $host = null,
    private ?int $priority = null,
    private ?Container<string> $schemes = null,
    private KeyedContainer<string, arraykey> $parameters = dict[],
  ) {
    $this->path = Str\format('/%s', Str\trim_left(Str\trim($path), '/'));

    if ($methods is nonnull) {
      $methods = Vec\map($methods, ($method) ==> Str\uppercase($method))
        |> Vec\unique($$);
    }
    $this->methods = $methods;

    if ($schemes is nonnull) {
      $schemes = Vec\map($schemes, ($scheme) ==> Str\lowercase($scheme))
        |> Vec\unique($$);
    }
    $this->schemes = $schemes;
  }

  public function getName(): string {
    return $this->name;
  }

  /**
   * Returns the pattern for the path.
   */
  public function getPath(): string {
    return $this->path;
  }

  /**
   * Returns the pattern for the host.
   */
  public function getHost(): ?string {
    return $this->host;
  }

  public function getPriority(): ?int {
    return $this->priority;
  }

  /**
   * Returns the lowercased schemes this route is restricted to.
   *
   * A null value means that any scheme is allowed.
   */
  public function getSchemes(): ?Container<string> {
    return $this->schemes;
  }

  /**
   * Returns the uppercased HTTP methods this route is restricted to.
   *
   * A null value means that any method is allowed.
   */
  public function getMethods(): ?Container<string> {
    return $this->methods;
  }

  /**
   * Returns the parameters.
   */
  public function getParameters(): KeyedContainer<string, arraykey> {
    return $this->parameters;
  }
}
