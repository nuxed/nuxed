namespace Nuxed\Http\Client;

use namespace Nuxed\Http\Message;

final class MockHttpClient extends HttpClient {
  public function __construct(
    private (function(Message\IRequest): Awaitable<Message\IResponse>) $handler,
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
  ): Awaitable<Message\IResponse> {
    return ($this->handler)($request);
  }
}
