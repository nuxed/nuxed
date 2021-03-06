/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Handler;

use namespace Nuxed\Http\Message;

/**
 * An HTTP request handler process a HTTP request and produces an HTTP response.
 * This interface defines the methods require to use the request handler.
 */
interface IHandler {
  /**
   * Handle the request and return a response.
   */
  public function handle(
    Message\IServerRequest $request,
  ): Awaitable<Message\IResponse>;
}
