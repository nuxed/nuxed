namespace Nuxed\Http\Router;

use namespace HH\Lib\{C, Str, Vec};
use namespace Nuxed\Http\Server\Handler;

final class Route {
  public function __construct(
    private string $path,
    private classname<Handler\IHandler> $handler,
    private ?Container<string> $methods = null,
    private ?string $host = null,
    private ?Container<string> $schemes = null,
    private KeyedContainer<string, arraykey> $parameters = dict[],
  ) {}

  /**
   * Returns the pattern for the path.
   */
  public function getPath(): string {
    return $this->path;
  }

  /**
   * Sets the pattern for the path.
   */
  public function setPath(string $path): this {
    $this->path = Str\format('/%s', Str\trim_left(Str\trim($path), '/'));

    return $this;
  }

  /**
   * Returns the pattern for the host.
   */
  public function getHost(): ?string {
    return $this->host;
  }

  /**
   * Sets the pattern for the host.
   */
  public function setHost(?string $host): this {
    $this->host = $host;

    return $this;
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
   * Sets the schemes (e.g. 'https') this route is restricted to.
   *
   * A null value means that any scheme is allowed.
   */
  public function setSchemes(?Container<string> $schemes): this {
    if ($schemes is nonnull) {
      $schemes = Vec\map($schemes, ($scheme) ==> Str\lowercase($scheme))
        |> Vec\unique($$);
    }

    $this->schemes = $schemes;

    return $this;
  }

  /**
   * Checks if a scheme requirement has been set.
   *
   * @return bool true if the scheme requirement exists, otherwise false
   */
  public function hasScheme(string $scheme): bool {
    return $this->schemes is null ||
      C\contains($this->schemes, Str\lowercase($scheme));
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
   * Sets the HTTP methods (e.g. 'POST') this route is restricted to.
   *
   * A null value means that any method is allowed.
   */
  public function setMethods(?Container<string> $methods): this {
    if ($methods is nonnull) {
      $methods = Vec\map($methods, ($method) ==> Str\uppercase($method))
        |> Vec\unique($$);
    }

    $this->methods = $methods;

    return $this;
  }

  /**
   * Returns the route handler.
   */
  public function getHandler(): classname<Handler\IHandler> {
    return $this->handler;
  }

  /**
   * Sets the handler.
   */
  public function setHandler(classname<Handler\IHandler> $handler): this {
    $this->handler = $handler;

    return $this;
  }

  /**
   * Sets the parameters.
   */
  public function setParameters(
    KeyedContainer<string, arraykey> $parameters,
  ): this {
    $this->parameters = dict[];

    return $this->addParameters($parameters);
  }

  /**
   * Adds parameter.
   */
  public function addParameters(
    KeyedContainer<string, arraykey> $parameters,
  ): this {
    $previous = dict($this->parameters);
    foreach ($parameters as $key => $value) {
      $previous[$key] = $value;
    }

    $this->parameters = $previous;

    return $this;
  }

  /**
   * Sets a parameter value.
   */
  public function setParameter(string $key, arraykey $value): this {
    return $this->addParameters(dict[$key => $value]);
  }

  /**
   * Checks if a parameter has been set.
   *
   * @return bool true if the parameter is set, false otherwise
   */
  public function hasParameter(string $key): bool {
    return C\contains_key($this->parameters, $key);
  }

  public function hasStringParameter(string $key): bool {
    return $this->hasParameter($key) && $this->getParameter($key) is string;
  }

  public function hasIntegerParameter(string $key): bool {
    return $this->hasParameter($key) && $this->getParameter($key) is int;
  }

  /**
   * Get a parameter value.
   */
  public function getParameter(string $key): arraykey {
    return $this->parameters[$key];
  }

  public function getStringParameter(string $key): string {
    return $this->getParameter($key) as string;
  }

  public function getIntegerParameter(string $key): int {
    $parameter = $this->getParameter($key);
    if ($parameter is int) {
      return $parameter;
    }

    $integer = Str\to_int($parameter as string);
    if ($integer is int) {
      return $integer;
    }

    return $parameter as int;
  }

  /**
   * Get an optional parameter value.
   */
  public function getOptionalParameter(string $key): ?arraykey {
    return $this->hasParameter($key) ? $this->getParameter($key) : null;
  }

  public function getOptionalStringParameter(string $key): ?string {
    return $this->hasParameter($key) ? $this->getStringParameter($key) : null;
  }

  public function getOptionalIntegerParameter(string $key): ?int {
    return $this->hasParameter($key) ? $this->getIntegerParameter($key) : null;
  }

  /**
   * Returns the parameter.
   */
  public function getParameters(): KeyedContainer<string, arraykey> {
    return $this->parameters;
  }
}
