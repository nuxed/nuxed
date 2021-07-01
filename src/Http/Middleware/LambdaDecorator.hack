/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Middleware;

use namespace Nuxed\Http\{Handler, Message, Middleware};

final class LambdaDecorator implements Middleware\IMiddleware {
  const type TLambda = (function(
    Message\IServerRequest,
    (function(Message\IServerRequest): Awaitable<Message\IResponse>),
  ): Awaitable<Message\IResponse>);

  public function __construct(private this::TLambda $middleware)[] {}

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
