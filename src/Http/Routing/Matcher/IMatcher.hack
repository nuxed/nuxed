/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http\Routing\Matcher;

use namespace Nuxed\Http\{Message, Routing};

interface IMatcher {
  /**
   * Match a request against the known routes.
   */
  public function match(
    Message\IRequest $request,
  ): Awaitable<(Routing\Route, KeyedContainer<string, string>)>;
}
