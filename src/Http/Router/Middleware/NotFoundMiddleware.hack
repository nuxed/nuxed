namespace Nuxed\Http\Router\Middleware;

use namespace Nuxed\Http\{Message, Router, Server};

final class NotFoundMiddleware implements Server\Middleware\IMiddleware {
  public function __construct() {}

  public async function process(
    Message\IServerRequest $request,
    Server\Handler\IHandler $handler,
  ): Awaitable<Message\IResponse> {
    try {
      return await $handler->handle($request);
    } catch (Router\Exception\NotFoundException $e) {
      return Message\response()
        ->withStatus(Message\StatusCode::NOT_FOUND);
    }
  }
}
