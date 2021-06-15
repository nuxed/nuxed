namespace Nuxed\Http\Handler;

use namespace Nuxed\Http\{Exception, Message};
use namespace Nuxed\Http\Handler;

/**
 * This handler is designed to always throw a {@see Exception\NotFoundException}.
 */
final class NotFoundHandler implements Handler\IHandler {
  public async function handle(
    Message\IServerRequest $request,
  ): Awaitable<Message\IResponse> {
    throw new Exception\NotFoundException();
  }
}
