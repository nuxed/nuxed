/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Middleware\_Private;

use namespace Nuxed\Http\{Handler, Message, Middleware};

final class NextMiddlewareHandler implements Handler\IHandler {
  private \SplPriorityQueue<Middleware\IMiddleware> $queue;

  public function __construct(
    \SplPriorityQueue<Middleware\IMiddleware> $queue,
    private Handler\IHandler $handler,
  ) {
    $this->queue = clone $queue;
  }

  public async function handle(
    Message\IServerRequest $request,
  ): Awaitable<Message\IResponse> {
    if (0 === $this->queue->count()) {
      return await $this->handler->handle($request);
    }

    $middleware = $this->queue->extract();

    return await $middleware->process($request, $this);
  }
}
