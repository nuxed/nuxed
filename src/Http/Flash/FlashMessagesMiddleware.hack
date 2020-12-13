namespace Nuxed\Http\Flash;

use namespace Nuxed\Http\Message;
use namespace Nuxed\Http\Server\{Handler, Middleware};

final class FlashMessagesMiddleware implements Middleware\IMiddleware {
  public function __construct(
    private string $key = FlashMessages::FLASH_NEXT,
  ) {}

  public async function process(
    Message\IServerRequest $request,
    Handler\IHandler $handler,
  ): Awaitable<Message\IResponse> {
    $session = $request->getSession();
    $flash = FlashMessages::create($session, $this->key);
    return await $handler->handle($request->withFlash($flash));
  }
}
