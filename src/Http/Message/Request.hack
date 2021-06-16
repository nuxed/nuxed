namespace Nuxed\Http\Message;

use namespace HH\Lib\{C, Dict, IO, Regex};
use namespace Nuxed\Http\Exception;

<<__Sealed(ServerRequest::class)>>
class Request extends Message<IO\SeekableReadHandle> implements IRequest {
  protected HttpMethod $method;

  protected ?string $requestTarget;

  protected IUri $uri;

  public function __construct(
    HttpMethod $method,
    IUri $uri,
    KeyedContainer<string, Container<string>> $headers = dict[],
    ?IO\SeekableReadHandle $body = null,
    string $version = '1.1',
  ) {
    $this->method = $method;
    $this->uri = $uri;
    $this->setHeaders($headers);
    $this->protocol = $version;

    if (!$this->hasHeader('Host')) {
      $this->updateHostFromUri();
    }

    if ($body is nonnull) {
      $this->body = $body;
    }
  }

  <<__Override>>
  public function __clone(): void {
    parent::__clone();

    $this->uri = clone $this->uri;
  }

  /**
   * Retrieves the message's request target.
   *
   * Retrieves the message's request-target either as it will appear (for
   * clients), as it appeared at request (for servers), or as it was
   * specified for the instance (see withRequestTarget()).
   *
   * In most cases, this will be the origin-form of the composed URI,
   * unless a value was provided to the concrete implementation (see
   * withRequestTarget() below).
   *
   * If no URI is available, and no request-target has been specifically
   * provided, this method will return the string "/".
   */
  public function getRequestTarget(): string {
    if ($this->requestTarget is nonnull) {
      return $this->requestTarget;
    }

    $target = $this->uri->getPath();
    if ('' === $target) {
      $target = '/';
    }

    $query = $this->uri->getQuery();
    if ($query is nonnull && '' !== $query) {
      $target .= '?'.$query;
    }

    $this->requestTarget = $target;
    return $target;
  }

  /**
   * Return an instance with the specific request-target.
   *
   * If the request needs a non-origin-form request-target — e.g., for
   * specifying an absolute-form, authority-form, or asterisk-form —
   * this method may be used to create an instance with the specified
   * request-target, verbatim.
   *
   * @link http://tools.ietf.org/html/rfc7230#section-5.3 (for the various
   *     request-target forms allowed in request messages)
   *
   * @throws Exception\InvalidArgumentException if the request target is invalid
   */
  public function withRequestTarget(string $request_target): this {
    if (Regex\matches($request_target, re"#\s#")) {
      throw new Exception\InvalidArgumentException(
        'Invalid request target provided; cannot contain whitespace',
      );
    }

    $new = clone $this;
    $new->requestTarget = $request_target;

    return $new;
  }

  /**
   * Retrieves the HTTP method of the request.
   */
  public function getMethod(): HttpMethod {
    return $this->method;
  }

  /**
   * Return an instance with the provided HTTP method.
   */
  public function withMethod(HttpMethod $method): this {
    $new = clone $this;
    $new->method = $method;

    return $new;
  }

  /**
   * Retrieves the URI instance.
   *
   * @link http://tools.ietf.org/html/rfc3986#section-4.3
   */
  public function getUri(): IUri {
    return $this->uri;
  }

  /**
   * Returns an instance with the provided URI.
   *
   * This method will update the Host header of the returned request by
   * default if the URI contains a host component. If the URI does not
   * contain a host component, any pre-existing Host header will be carried
   * over to the returned request.
   *
   * You can opt-in to preserving the original state of the Host header by
   * setting `$preserveHost` to `true`. When `$preserveHost` is set to
   * `true`, this method interacts with the Host header in the following ways:
   *
   * @link http://tools.ietf.org/html/rfc3986#section-4.3
   */
  public function withUri(IUri $uri, bool $preserve_host = false): this {
    if ($uri === $this->uri) {
      return $this;
    }

    $new = clone $this;
    $new->uri = $uri;
    $new->requestTarget = null;
    if (!$preserve_host || !$this->hasHeader('Host')) {
      $new->updateHostFromUri();
    }

    return $new;
  }

  /**
   * Gets the body of the message.
   */
  <<__Override>>
  public function getBody(): IO\SeekableReadHandle {
    if ($this->body is null) {
      $this->body = Body\temporary();
    }

    return $this->body as nonnull;
  }

  protected function updateHostFromUri(): void {
    $host = $this->uri->getHost();
    if ($host is null) {
      return;
    }

    $port = $this->uri->getPort();
    $schema = $this->uri->getScheme();

    if (
      $port is nonnull &&
      $schema is nonnull &&
      !Uri::isStandardPort($schema, $port)
    ) {
      $host .= ':'.((string)$port);
    }

    if (C\contains_key($this->headerNames, 'host')) {
      $header = $this->headerNames['host'];
    } else {
      $header = 'Host';
      $this->headerNames['host'] = 'Host';
    }

    if (C\contains_key($this->headers, $header)) {
      unset($this->headers[$header]);
    }

    $this->headers = Dict\merge(dict[$header => vec[$host]], $this->headers);
  }

}
