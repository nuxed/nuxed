/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Routing;

use namespace HH\Lib\Str;
use namespace Nuxed\Http\{Handler, Message};

final class Route {
  private string $name;

  public function __construct(
    private string $path,
    private Container<Message\HttpMethod> $methods,
    private Handler\IHandler $handler,
    private int $priority = 0,
  )[] {
    $this->name = Str\format(
      '%s[%s]',
      Str\replace($path, '/', '-'),
      Str\join($methods, '|'),
    );
  }

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
