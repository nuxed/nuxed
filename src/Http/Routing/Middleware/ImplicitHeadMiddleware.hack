/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Routing\Middleware;

use namespace HH\Lib\C;
use namespace Nuxed\Http\{Exception, Handler, Message, Middleware};

/**
 * Handle implicit HEAD requests.
 *
 * Place this middleware after the routing middleware so that it can handle
 * implicit HEAD requests: requests where HEAD is used, but the route does
 * not explicitly handle that request method.
 */
final class ImplicitHeadMiddleware implements Middleware\IMiddleware {
  const string ForwardedHttpMethodAttribute = 'FORWARDED_HTTP_METHOD';

  /**
   * Handle an implicit HEAD request.
   *
   * If the route allows GET requests, dispatches as a GET request and
   * resets the response body to be empty; otherwise, creates a new empty
   * response.
   */
  public async function process(
    Message\IServerRequest $request,
    Handler\IHandler $handler,
  ): Awaitable<Message\IResponse> {
    try {
      return await $handler->handle($request);
    } catch (Exception\MethodNotAllowedException $e) {
      if ($request->getMethod() !== Message\HttpMethod::HEAD) {
        throw $e;
      }

      $allowedMethods = $e->getAllowedMethods();
      if (
        C\count($allowedMethods) !== 1 ||
        C\contains($allowedMethods, Message\HttpMethod::GET)
      ) {
        // Only reroute GET -> HEAD, otherwise the application might fall into a security trap.
        // see: https://blog.teddykatz.com/2019/11/05/github-oauth-bypass.html
        throw $e;
      }

      $response = await $handler->handle(
        $request->withMethod(Message\HttpMethod::GET)
          ->withAttribute<string>(
            self::ForwardedHttpMethodAttribute,
            (string)Message\HttpMethod::HEAD,
          ),
      );

      return $response->withBody(Message\Body\memory());
    }
  }
}
