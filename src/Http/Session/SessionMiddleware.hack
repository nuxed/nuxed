namespace Nuxed\Http\Session;

use namespace Nuxed\Http\Message;
use namespace Nuxed\Http\Server\{Handler, Middleware};

class SessionMiddleware implements Middleware\IMiddleware {
  public function __construct(
    private Persistence\ISessionPersistence $persistence,
  ) {}

  public async function process(
    Message\IServerRequest $request,
    Handler\IHandler $handler,
  ): Awaitable<Message\IResponse> {
    $session = await $this->persistence->initialize($request);
    $request = $request->withSession($session);
    $response = await $handler->handle($request);

    return await $this->persistence->persist($request->getSession(), $response);
  }
}
