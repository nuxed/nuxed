namespace Nuxed\Http\Client;

use namespace Nuxed\Http\Message;

interface IHttpClient {
  const HttpClientOptions DEFAULT_OPTIONS = shape(
    'headers' => dict[],
    'max_redirects' => 20,
    'bindto' => '0',
    'verify_peer' => true,
    'verify_host' => true,
    'capture_peer_cert_chain' => false,
  );

  /**
   * Sends a request and returns a response.
   *
   * @throws Exception\IException If an error happens while processing the request.
   */
  public function send(
    Message\Request $request,
    HttpClientOptions $options = shape(),
  ): Awaitable<Message\Response>;

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
  ): Awaitable<Message\Response>;
}
