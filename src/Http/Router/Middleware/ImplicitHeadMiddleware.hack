namespace Nuxed\Http\Router\Middleware;

use namespace HH\Lib\C;
use namespace Nuxed\Http\{Message, Router, Server};

/**
 * Handle implicit HEAD requests.
 *
 * Place this middleware after the routing middleware so that it can handle
 * implicit HEAD requests: requests where HEAD is used, but the route does
 * not explicitly handle that request method.
 */
final class ImplicitHeadMiddleware implements Server\Middleware\IMiddleware {
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
    Server\Handler\IHandler $handler,
  ): Awaitable<Message\IResponse> {
    try {
      return await $handler->handle($request);
    } catch (Router\Exception\MethodNotAllowedException $e) {
      if ($request->getMethod() !== Message\RequestMethod::HEAD) {
        throw $e;
      }

      $allowedMethods = $e->getAllowedMethods();
      if (
        C\count($allowedMethods) !== 1 ||
        C\contains($allowedMethods, Message\RequestMethod::GET)
      ) {
        // Only reroute GET -> HEAD, otherwise the application might fall into a security trap.
        // see: https://blog.teddykatz.com/2019/11/05/github-oauth-bypass.html
        throw $e;
      }

      $response = await $handler->handle(
        $request->withMethod(Message\RequestMethod::GET)
          ->withAttribute<string>(
            self::ForwardedHttpMethodAttribute,
            Message\RequestMethod::HEAD,
          ),
      );

      return $response->withBody(Message\Body\temporary());
    }
  }
}
