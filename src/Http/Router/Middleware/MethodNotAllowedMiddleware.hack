namespace Nuxed\Http\Router\Middleware;

use namespace Nuxed\Http\{Message, Router, Server};

final class MethodNotAllowedMiddleware
  implements Server\Middleware\IMiddleware {
  public function __construct() {}

  public async function process(
    Message\IServerRequest $request,
    Server\Handler\IHandler $handler,
  ): Awaitable<Message\IResponse> {
    try {
      return await $handler->handle($request);
    } catch (Router\Exception\MethodNotAllowedException $e) {
      return Message\response()
        ->withStatus(Message\StatusCode::METHOD_NOT_ALLOWED)
        ->withHeader('Allow', $e->getAllowedMethods());
    }
  }
}
