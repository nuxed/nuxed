namespace Nuxed\Http\Routing;

use namespace Nuxed\Http\{Handler, Message};

trait RouterConvenienceMethodsTrait {
  require implements IRouteCollector;

  public function get(
    string $name,
    string $path,
    Handler\IHandler $handler,
    int $priority = 0,
  ): this {
    return $this->addRoute(
      new Route(
        $name,
        $path,
        keyset[Message\HttpMethod::GET],
        $handler,
        $priority,
      ),
    );
  }

  public function head(
    string $name,
    string $path,
    Handler\IHandler $handler,
    int $priority = 0,
  ): this {
    return $this->addRoute(
      new Route(
        $name,
        $path,
        keyset[Message\HttpMethod::HEAD],
        $handler,
        $priority,
      ),
    );
  }

  public function post(
    string $name,
    string $path,
    Handler\IHandler $handler,
    int $priority = 0,
  ): this {
    return $this->addRoute(
      new Route(
        $name,
        $path,
        keyset[Message\HttpMethod::POST],
        $handler,
        $priority,
      ),
    );
  }

  public function put(
    string $name,
    string $path,
    Handler\IHandler $handler,
    int $priority = 0,
  ): this {
    return $this->addRoute(
      new Route(
        $name,
        $path,
        keyset[Message\HttpMethod::PUT],
        $handler,
        $priority,
      ),
    );
  }

  public function patch(
    string $name,
    string $path,
    Handler\IHandler $handler,
    int $priority = 0,
  ): this {
    return $this->addRoute(
      new Route(
        $name,
        $path,
        keyset[Message\HttpMethod::PATCH],
        $handler,
        $priority,
      ),
    );
  }

  public function delete(
    string $name,
    string $path,
    Handler\IHandler $handler,
    int $priority = 0,
  ): this {
    return $this->addRoute(
      new Route(
        $name,
        $path,
        keyset[Message\HttpMethod::DELETE],
        $handler,
        $priority,
      ),
    );
  }
}
