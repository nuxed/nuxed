namespace Nuxed\Http\Middleware;

use namespace Nuxed\Http\Middleware;

function path(
  string $path,
  Middleware\IMiddleware $middleware,
)[]: PathDecorator {
  return new PathDecorator($path, $middleware);
}
