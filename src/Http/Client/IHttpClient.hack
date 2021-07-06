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

interface IHttpClient {
  const HttpClientOptions DEFAULT_OPTIONS = shape(
    'headers' => dict[],
    'max_redirects' => 20,
    'verify_peer' => true,
    'verify_host' => true,
    'capture_peer_cert_chain' => false,
    'connect_timeout' => 30.0,
    'timeout' => 60.0,
    'debug' => false,
  );

  /**
   * Sends a request and returns a response.
   *
   * @throws Exception\IException If an error happens while processing the request.
   */
  public function send(
    Message\IRequest $request,
    HttpClientOptions $options = shape(),
  ): Awaitable<Message\IResponse>;

  /**
   * Create and send an HTTP request.
   *
   * Use an absolute path to override the base path of the client, or a
   * relative path to append to the base path of the client. The URL can
   * contain the query string as well.
   *
   * @throws Exception\IException If an error happens while processing the request.
   */
  public function request(
    string $method,
    string $uri,
    HttpClientOptions $options = shape(),
  ): Awaitable<Message\IResponse>;
}
