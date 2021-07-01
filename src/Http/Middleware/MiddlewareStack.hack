/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http\Middleware;

use namespace Nuxed\Http\{Handler, Message};

final class MiddlewareStack implements IMiddlewareStack {
  private \SplPriorityQueue<IMiddleware> $stack;

  public function __construct() {
    $this->stack = new \SplPriorityQueue<IMiddleware>();
  }

  public function __clone(): void {
    $this->stack = clone $this->stack;
  }

  /**
   * Attach middleware to the stack.
   */
  public function stack(IMiddleware $middleware, int $priority = 0): this {
    $this->stack->insert($middleware, $priority);

    return $this;
  }

  /**
   * Middleware invocation.
   *
   * Executes the internal stack, passing $handler as the "final
   * handler" in cases when the stack exhausts itself.
   */
  public async function process(
    Message\IServerRequest $request,
    Handler\IHandler $handler,
  ): Awaitable<Message\IResponse> {
    $next = new _Private\NextMiddlewareHandler($this->stack, $handler);
    return await $next->handle($request);
  }
}
