namespace Nuxed\Http\Server\Middleware\Decorator;

use namespace HH\Lib\Str;
use namespace Nuxed\Http\Message;
use namespace Nuxed\Http\Server\{Handler, Middleware};

final class HostDecorator implements Middleware\IMiddleware {
  public function __construct(
    private string $host,
    private Middleware\IMiddleware $middleware,
  ) {}

  public async function process(
    Message\IServerRequest $request,
    Handler\IHandler $handler,
  ): Awaitable<Message\IResponse> {
    $host = $request->getUri()->getHost();

    if ($host !== Str\lowercase($this->host)) {
      return await $handler->handle($request);
    }

    return await $this->middleware->process($request, $handler);
  }
}
