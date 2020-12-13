namespace Nuxed\Http\Server\Handler\Decorator;

use namespace Nuxed\Http\Message;
use namespace Nuxed\Http\Server\Handler;

final class LambdaDecorator implements Handler\IHandler {
  const type TLambda = (function(
    Message\IServerRequest,
  ): Awaitable<Message\IResponse>);

  public function __construct(private this::TLambda $callback) {}

  public async function handle(
    Message\IServerRequest $request,
  ): Awaitable<Message\IResponse> {
    $fun = $this->callback;
    return await $fun($request);
  }
}
