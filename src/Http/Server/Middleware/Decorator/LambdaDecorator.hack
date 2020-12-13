namespace Nuxed\Http\Server\Middleware\Decorator;

use namespace Nuxed\Http\Message;
use namespace Nuxed\Http\Server\{Handler, Middleware};

final class LambdaDecorator implements Middleware\IMiddleware {
  const type TLambda = (function(
    Message\IServerRequest,
    (function(Message\IServerRequest): Awaitable<Message\IResponse>),
  ): Awaitable<Message\IResponse>);

  public function __construct(private this::TLambda $middleware) {}

  public function process(
    Message\IServerRequest $request,
    Handler\IHandler $handler,
  ): Awaitable<Message\IResponse> {
    $fun = $this->middleware;
    return $fun(
      $request,
      async (Message\IServerRequest $request): Awaitable<Message\IResponse> ==>
        await $handler->handle($request),
    );
  }
}
