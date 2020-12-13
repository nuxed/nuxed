namespace Nuxed\Http\Router\Middleware;

use namespace Nuxed\Http\{Message, Router, Server};

/**
 * Default routing middleware.
 */
final class RouteMiddleware implements Server\Middleware\IMiddleware {
  public function __construct(
    protected Router\Matcher\IRequestMatcher $matcher,
  ) {}

  public async function process(
    Message\IServerRequest $request,
    Server\Handler\IHandler $handler,
  ): Awaitable<Message\IResponse> {
    $route = await $this->matcher->match($request);
    foreach ($route->getParameters() as $key => $value) {
      $request = $request->withAttribute<arraykey>($key, $value);
    }

    $request = $request->withAttribute<Router\Route>(
      Router\Route::class,
      $route,
    );

    return await $handler->handle($request);
  }
}
