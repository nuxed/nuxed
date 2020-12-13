namespace Nuxed\Http\Router\Middleware;

use namespace Nuxed\{DependencyInjection, Http};
use namespace Nuxed\Http\Router;

/**
 * Default dispatch middleware.
 *
 * Checks for a composed route result in the request. If none is provided,
 * delegates request processing to the handler.
 *
 * Otherwise, it delegates processing to the route result.
 */
final class DispatchMiddleware implements Http\Server\Middleware\IMiddleware {
  public function __construct(
    private DependencyInjection\IServiceContainer $container,
  ) {}

  public async function process(
    Http\Message\IServerRequest $request,
    Http\Server\Handler\IHandler $handler,
  ): Awaitable<Http\Message\IResponse> {
    if (!$request->hasAttribute(Router\Route::class)) {
      return await $handler->handle($request);
    }
    $route = $request->getAttribute<Router\Route>(Router\Route::class);
    $handler = $this->container
      ->get<Http\Server\Handler\IHandler>($route->getHandler());

    return await $handler->handle($request);
  }
}
