/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http\Flash\Middleware;

use namespace Nuxed\Http\{Flash, Handler, Message, Middleware};

final class FlashMessagesMiddleware implements Middleware\IMiddleware {
  public function __construct(
    private string $key = Flash\FlashMessages::FLASH_NEXT,
  ) {}

  public async function process(
    Message\IServerRequest $request,
    Handler\IHandler $handler,
  ): Awaitable<Message\IResponse> {
    $session = $request->getSession();
    $flash = Flash\FlashMessages::create($session, $this->key);
    return await $handler->handle($request->withFlash($flash));
  }
}
