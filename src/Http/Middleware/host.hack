namespace Nuxed\Http\Middleware;

use namespace Nuxed\Http\Middleware;

function host(string $host, Middleware\IMiddleware $middleware): HostDecorator {
  return new HostDecorator($host, $middleware);
}
