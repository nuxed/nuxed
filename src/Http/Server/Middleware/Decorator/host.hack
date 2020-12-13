namespace Nuxed\Http\Server\Middleware\Decorator;

use namespace Nuxed\Http\Server\Middleware;

function host(string $host, Middleware\IMiddleware $middleware): HostDecorator {
  return new HostDecorator($host, $middleware);
}
