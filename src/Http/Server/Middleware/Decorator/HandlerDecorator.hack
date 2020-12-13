namespace Nuxed\Http\Server\Middleware\Decorator;

use namespace Nuxed\Http\Message;
use namespace Nuxed\Http\Server\{Handler, Middleware};

/**
 * Decorate a request handler as middleware.
 *
 * When pulling handlers from a container, or creating pipelines, it's
 * simplest if everything is of the same type, so we do not need to worry
 * about varying execution based on type.
 *
 * To manage this, this class decorates request handlers as middleware, so that
 * they may be piped or routed to. When processed, they delegate handling to the
 * decorated handler, which will return a response.
 */
final class HandlerDecorator
  implements Middleware\IMiddleware, Handler\IHandler {
  public function __construct(private Handler\IHandler $handler) {}

  /**
   * Proxies to decorated handler to handle the request.
   */
  public function handle(
    Message\IServerRequest $request,
  ): Awaitable<Message\IResponse> {
    return $this->handler->handle($request);
  }

  /**
   * Proxies to decorated handler to handle the request.
   */
  public function process(
    Message\IServerRequest $request,
    Handler\IHandler $_handler,
  ): Awaitable<Message\IResponse> {
    return $this->handler->handle($request);
  }
}
