namespace Nuxed\Http\Routing;

use namespace HH\Lib\{C, Str, Vec};
use namespace Nuxed\Http\Message;
use namespace Nuxed\Http\Handler;

final class Route {
  public function __construct(
    private string $name,
    private string $path,
    private Container<Message\HttpMethod> $methods,
    private Handler\IHandler $handler,
    private int $priority = 0,
  )[] {}

  public function getName()[]: string {
    return $this->name;
  }

  /**
   * Returns the pattern for the path.
   */
  public function getPath()[]: string {
    return $this->path;
  }

  /**
   * Returns the uppercased HTTP methods this route is restricted to.
   *
   * A null value means that any method is allowed.
   */
  public function getMethods()[]: Container<Message\HttpMethod> {
    return $this->methods;
  }

  /**
   * Returns the route handler.
   */
  public function getHandler()[]: Handler\IHandler {
    return $this->handler;
  }

  /**
   * Return priority.
   */
  public function getPriority()[]: int {
    return $this->priority;
  }
}
