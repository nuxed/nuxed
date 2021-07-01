/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http\Middleware;

use namespace Nuxed\Http\{Handler, Message, Middleware};

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
