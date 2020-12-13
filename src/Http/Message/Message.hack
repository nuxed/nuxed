namespace Nuxed\Http\Message;

use namespace HH\Lib\{C, IO, Regex, Str, Vec};
use namespace Nuxed\Http\Message;

/**
 * Abstract class implementing functionality common to requests and responses.
 */
<<__Sealed(Response::class, Request::class)>>
abstract class Message<T as IO\SeekableHandle> implements Message\IMessage<T> {
  /**
   * dictonary of all registered headers, as original name => Set of values
   */
  protected dict<string, vec<string>> $headers = dict[];

  /**
   * dictonary of lowercase header name => original name at registration
   */
  protected dict<string, string> $headerNames = dict[];

  /**
   * Protocol version number.
   */
  protected string $protocol = '1.1';

  /**
   * Message body
   */
  protected ?T $body;

  /**
   * Retrieves the HTTP protocol version as a string.
   */
  public function getProtocolVersion(): string {
    return $this->protocol;
  }

  /**
   * Return an instance with the specified HTTP protocol version.
   *
   * The version string contains only the HTTP version number (e.g.,
   * "1.1", "1.0").
   */
  public function withProtocolVersion(string $version): this {
    if ($this->protocol === $version) {
      return $this;
    }

    $new = clone $this;
    $new->protocol = $version;

    return $new;
  }

  /**
   * Retrieves all message header values.
   *
   * The keys represent the header name as it will be sent over the wire, and
   * each value is a container of strings associated with the header.
   *
   *     // Represent the headers as a string
   *     foreach ($message->getHeaders() as $name => $values) {
   *         echo $name . ": " . Str\join($values, ', ');
   *     }
   *
   *     // Emit headers iteratively:
   *     foreach ($message->getHeaders() as $name => $values) {
   *         foreach ($values as $value) {
   *             header(Str\format('%s: %s', $name, $value), false);
   *         }
   *     }
   *
   * While header names are not case-sensitive, getHeaders() will preserve the
   * exact case in which headers were originally specified.
   */
  public function getHeaders(): KeyedContainer<string, Container<string>> {
    return $this->headers;
  }

  /**
   * Checks if a header exists by the given case-insensitive name.
   *
   * @return bool Returns true if any header names match the given header
   *     name using a case-insensitive string comparison. Returns false if
   *     no matching header name is found in the message.
   */
  public function hasHeader(string $header): bool {
    return C\contains_key($this->headerNames, Str\lowercase($header));
  }

  /**
   * Retrieves a message header value by the given case-insensitive name.
   *
   * This method returns a container of all the header values of the given
   * case-insensitive header name.
   *
   * If the header does not appear in the message, this method will return an
   * empty container.
   */
  public function getHeader(string $header): Container<string> {
    $header = Str\lowercase($header);

    $header = $this->headerNames[$header] ?? null;

    if ($header is null) {
      return vec[];
    }

    return $this->headers[$header] ?? vec[];
  }

  /**
   * Retrieves a comma-separated string of the values for a single header.
   *
   * This method returns all of the header values of the given
   * case-insensitive header name as a string concatenated together using
   * a comma.
   *
   * NOTE: Not all header values may be appropriately represented using
   * comma concatenation. For such headers, use getHeader() instead
   * and supply your own delimiter when concatenating.
   *
   * If the header does not appear in the message, this method will return
   * an empty string.
   */
  public function getHeaderLine(string $header): string {
    return Str\join($this->getHeader($header), ', ');
  }

  /**
   * Return an instance with the provided value replacing the specified header.
   *
   * While header names are case-insensitive, the casing of the header will
   * be preserved by this function, and returned from getHeaders().
   *
   * @throws Exception\InvalidArgumentException for invalid header names or values.
   */
  public function withHeader(string $header, Container<string> $value): this {
    $value = $this->validateAndTrimHeader($header, $value);

    $normalized = Str\replace(Str\lowercase($header), '_', '-');

    $new = clone $this;

    if (C\contains_key($new->headerNames, $normalized)) {
      unset($new->headers[$new->headerNames[$normalized]]);
    }

    $new->headerNames[$normalized] = $header;
    $new->headers[$header] = vec($value);

    return $new;
  }

  /**
   * Return an instance with the specified header appended with the given value.
   *
   * Existing values for the specified header will be maintained. The new
   * value(s) will be appended to the existing list. If the header did not
   * exist previously, it will be added.
   *
   * @throws Exception\InvalidArgumentException for invalid header names or values.
   */
  public function withAddedHeader(
    string $header,
    Container<string> $value,
  ): this {
    if ('' === $header) {
      throw new Exception\InvalidArgumentException(
        'Header name must be an RFC 7230 compatible string.',
      );
    }

    $new = clone $this;
    $new->setHeaders(dict[
      $header => $value,
    ]);

    return $new;
  }

  /**
   * Return an instance without the specified header.
   */
  public function withoutHeader(string $header): this {
    $normalized = Str\replace(Str\lowercase($header), '_', '-');

    if (!C\contains_key($this->headerNames, $normalized)) {
      return $this;
    }

    $header = $this->headerNames[$normalized];

    $new = clone $this;

    unset($new->headerNames[$normalized]);
    unset($new->headers[$header]);

    return $new;
  }

  /**
   * Gets the body of the message.
   */
  abstract public function getBody(): T;

  /**
   * Return an instance with the specified message body.
   */
  public function withBody(T $body): this {
    if ($body === $this->body) {
      return $this;
    }

    $new = clone $this;
    $new->body = $body;

    return $new;
  }

  protected function setHeaders(
    KeyedContainer<string, Container<string>> $headers,
  ): void {
    foreach ($headers as $header => $value) {
      $value = $this->validateAndTrimHeader($header, $value);

      $normalized = Str\replace(Str\lowercase($header), '_', '-');

      if (C\contains_key($this->headerNames, $normalized)) {
        $header = $this->headerNames[$normalized];
        $this->headers[$header] = Vec\unique(
          Vec\concat($this->headers[$header], $value),
        );
      } else {
        $this->headerNames[$normalized] = $header;
        $this->headers[$header] = vec($value);
      }
    }
  }

  /**
   * Make sure the header complies with RFC 7230.
   *
   * Header names must be a non-empty string consisting of token characters.
   *
   * Header values must be strings consisting of visible characters with all optional
   * leading and trailing whitespace stripped. This method will always strip such
   * optional whitespace. Note that the method does not allow folding whitespace within
   * the values as this was deprecated for almost all instances by the RFC.
   *
   * header-field = field-name ":" OWS field-value OWS
   * field-name   = 1*( "!" / "#" / "$" / "%" / "&" / "'" / "*" / "+" / "-" / "." / "^"
   *              / "_" / "`" / "|" / "~" / %x30-39 / ( %x41-5A / %x61-7A ) )
   * OWS          = *( SP / HTAB )
   * field-value  = *( ( %x21-7E / %x80-FF ) [ 1*( SP / HTAB ) ( %x21-7E / %x80-FF ) ] )
   *
   * @see https://tools.ietf.org/html/rfc7230#section-3.2.4
   */
  protected function validateAndTrimHeader(
    string $header,
    Container<string> $values,
  ): Container<string> {
    if (!Regex\matches($header, re"@^[!#$%&'*+.^_`|~0-9A-Za-z-]+$@")) {
      throw new Exception\InvalidArgumentException(
        'Header name must be an RFC 7230 compatible string.',
      );
    }

    if (0 === C\count($values)) {
      throw new Exception\InvalidArgumentException(
        'Header values must be a container of strings, empty container given.',
      );
    }

    $retval = vec[];

    foreach ($values as $value) {

      if (!Regex\matches($value, re"@^[ \t\x21-\x7E\x80-\xFF]*$@")) {
        throw new Exception\InvalidArgumentException(
          'Header values must be RFC 7230 compatible strings.',
        );
      }

      $retval[] = Str\trim($value, " \t");
    }

    return $retval;
  }

  public function __clone(): void {
    $this->body = $this->body is null ? null : (clone $this->body);
  }
}
