/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http\Routing\Middleware;

use namespace Nuxed\Http\{Handler, Message, Middleware, Routing};

/**
 * Default routing middleware.
 */
final class RouteMiddleware implements Middleware\IMiddleware {
  public function __construct(protected Routing\Matcher\IMatcher $matcher) {}

  public async function process(
    Message\IServerRequest $request,
    Handler\IHandler $handler,
  ): Awaitable<Message\IResponse> {
    list($route, $parameters) = await $this->matcher->match($request);
    foreach ($parameters as $key => $value) {
      $request = $request->withAttribute<string>($key, $value);
    }

    $request = $request->withAttribute<Routing\Route>(
      Routing\Route::class,
      $route,
    );

    return await $handler->handle($request);
  }
}
