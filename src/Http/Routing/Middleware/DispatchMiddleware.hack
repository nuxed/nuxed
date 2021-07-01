/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http\Routing\Middleware;

use namespace Nuxed\Http;
use namespace Nuxed\Http\Routing;

/**
 * Default dispatch middleware.
 *
 * Checks for a composed route result in the request. If none is provided,
 * delegates request processing to the handler.
 *
 * Otherwise, it delegates processing to the route result.
 */
final class DispatchMiddleware implements Http\Middleware\IMiddleware {
  public async function process(
    Http\Message\IServerRequest $request,
    Http\Handler\IHandler $handler,
  ): Awaitable<Http\Message\IResponse> {
    if (!$request->hasAttribute(Routing\Route::class)) {
      return await $handler->handle($request);
    }

    $route = $request->getAttribute<Routing\Route>(Routing\Route::class);

    return await $route->getHandler()->handle($request);
  }
}
