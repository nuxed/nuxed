namespace Nuxed\Http\Server\Middleware\Decorator;

use namespace Nuxed\Http\Server\Middleware;

function path(string $path, Middleware\IMiddleware $middleware): PathDecorator {
  return new PathDecorator($path, $middleware);
}
