/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Client;

use namespace Nuxed\Http\Message;

final class MockHttpClient extends HttpClient {
  public function __construct(
    private (function(
      Message\IRequest,
      HttpClientOptions,
    ): Awaitable<Message\IResponse>) $handler,
    HttpClientOptions $options = shape(),
  ) {
    parent::__construct($options);
  }

  /**
   * Process the request and returns a response.
   *
   * @throws Exception\IException If an error happens while processing the request.
   */
  <<__Override>>
  public function process(
    Message\IRequest $request,
    HttpClientOptions $options,
  ): Awaitable<Message\IResponse> {
    return ($this->handler)($request, $options);
  }
}
