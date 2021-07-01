/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Handler;

use namespace Nuxed\Http\{Handler, Message};

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
