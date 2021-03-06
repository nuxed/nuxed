/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Routing\Middleware;

use namespace Nuxed\Http\{Exception, Handler, Message, Middleware};

/**
 * Handle implicit OPTIONS requests.
 *
 * Place this middleware after the routing middleware so that it can handle
 * implicit OPTIONS requests: requests where OPTIONS is used, but the route
 * does not explicitly handle that request method.
 *
 * When invoked, it will create a response with status code 200 and an Allow
 * header that defines all accepted request methods.
 *
 * You may optionally pass a response prototype to the constructor; when
 * present, that prototype will be used to create a new response with the
 * Allow header.
 *
 * The middleware is only invoked in these specific conditions:
 *
 * - an OPTIONS request
 * - with a `RouteResult` present
 * - where the `RouteResult` contains a `Route` instance
 * - and the `Route` instance defines implicit OPTIONS.
 *
 * In all other circumstances, it will return the result of the delegate.
 */
final class ImplicitOptionsMiddleware implements Middleware\IMiddleware {
  public function __construct(private ?Message\IResponse $response = null) {}

  /**
   * Handle an implicit OPTIONS request.
   */
  public async function process(
    Message\IServerRequest $request,
    Handler\IHandler $handler,
  ): Awaitable<Message\IResponse> {
    try {
      return await $handler->handle($request);
    } catch (Exception\MethodNotAllowedException $e) {
      if ($request->getMethod() !== Message\HttpMethod::OPTIONS) {
        throw $e;
      }

      return $e->toResponse()->withStatus(Message\StatusCode::NO_CONTENT);
    }
  }
}
