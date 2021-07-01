/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http\Handler;

use namespace Nuxed\Http\{Exception, Handler, Message};

/**
 * This handler is designed to always throw a {@see Exception\NotFoundException}.
 */
final class NotFoundHandler implements Handler\IHandler {
  public async function handle(
    Message\IServerRequest $_request,
  ): Awaitable<Message\IResponse> {
    throw new Exception\NotFoundException();
  }
}
