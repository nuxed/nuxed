/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Session\Persistence;

use namespace Nuxed\Http\{Message, Session};

interface ISessionPersistence {
  /**
   * Generate a session data instance based on the request.
   */
  public function initialize(
    Message\IServerRequest $request,
  ): Awaitable<Session\ISession>;

  /**
   * Persist the session data instance
   *
   * Persists the session data, returning a response instance with any
   * artifacts required to return to the client.
   */
  public function persist(
    Session\ISession $session,
    Message\IResponse $response,
  ): Awaitable<Message\IResponse>;
}
