namespace Nuxed\Http\Session\Middleware;

use namespace Nuxed\Http\{Handler, Message, Middleware, Session};

final class InitializationMiddleware implements Middleware\IMiddleware {
  public function __construct(
    private Session\Persistence\ISessionPersistence $persistence,
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
