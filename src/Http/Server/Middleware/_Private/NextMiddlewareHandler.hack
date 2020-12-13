namespace Nuxed\Http\Server\Middleware\_Private;

use namespace Nuxed\Http\Server\{Handler, Middleware};
use namespace Nuxed\Http\Message;

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
