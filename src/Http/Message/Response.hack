namespace Nuxed\Http\Message;

use namespace HH\Lib\{C, IO};
use namespace Nuxed\Http\{Exception, Message};

<<__Sealed(Response\JsonResponse::class)>>
class Response
  extends Message<IO\SeekableReadWriteHandle>
  implements Message\IResponse {
  /** Map of standard HTTP status code/reason phrases */
  public static dict<int, string> $phrases = dict[
    100 => 'Continue',
    101 => 'Switching Protocols',
    102 => 'Processing',
    200 => 'OK',
    201 => 'Created',
    202 => 'Accepted',
    203 => 'Non-Authoritative Information',
    204 => 'No Content',
    205 => 'Reset Content',
    206 => 'Partial Content',
    207 => 'Multi-status',
    208 => 'Already Reported',
    300 => 'Multiple Choices',
    301 => 'Moved Permanently',
    302 => 'Found',
    303 => 'See Other',
    304 => 'Not Modified',
    305 => 'Use Proxy',
    306 => 'Switch Proxy',
    307 => 'Temporary Redirect',
    400 => 'Bad Request',
    401 => 'Unauthorized',
    402 => 'Payment Required',
    403 => 'Forbidden',
    404 => 'Not Found',
    405 => 'Method Not Allowed',
    406 => 'Not Acceptable',
    407 => 'Proxy Authentication Required',
    408 => 'Request Time-out',
    409 => 'Conflict',
    410 => 'Gone',
    411 => 'Length Required',
    412 => 'Precondition Failed',
    413 => 'Request Entity Too Large',
    414 => 'Request-URI Too Large',
    415 => 'Unsupported Media Type',
    416 => 'Requested range not satisfiable',
    417 => 'Expectation Failed',
    418 => 'I\'m a teapot',
    422 => 'Unprocessable Entity',
    423 => 'Locked',
    424 => 'Failed Dependency',
    425 => 'Unordered Collection',
    426 => 'Upgrade Required',
    428 => 'Precondition Required',
    429 => 'Too Many Requests',
    431 => 'Request Header Fields Too Large',
    451 => 'Unavailable For Legal Reasons',
    500 => 'Internal Server Error',
    501 => 'Not Implemented',
    502 => 'Bad Gateway',
    503 => 'Service Unavailable',
    504 => 'Gateway Time-out',
    505 => 'HTTP Version not supported',
    506 => 'Variant Also Negotiates',
    507 => 'Insufficient Storage',
    508 => 'Loop Detected',
    511 => 'Network Authentication Required',
  ];

  private dict<string, Message\ICookie> $cookies = dict[];

  private ?string $reasonPhrase = null;

  private int $statusCode = 200;

  private ?string $charset = null;

  public function __construct(
    int $status = 200,
    KeyedContainer<string, Container<string>> $headers = dict[],
    ?IO\SeekableReadWriteHandle $body = null,
    string $version = '1.1',
    ?string $reason = null,
  ) {
    $this->assertValidStatusCode($status);
    $this->statusCode = $status;
    $this->setHeaders($headers);

    if ($reason is null && C\contains_key(self::$phrases, $status)) {
      $this->reasonPhrase = self::$phrases[$status];
    } else {
      $this->reasonPhrase = $reason;
    }

    $this->protocol = $version;
    $this->body = $body;
  }

  <<__Override>>
  public function __clone(): void {
    parent::__clone();
  }

  /**
   * Gets the response status code.
   *
   * The status code is a 3-digit integer result code of the server's attempt
   * to understand and satisfy the request.
   */
  public function getStatusCode(): int {
    return $this->statusCode;
  }

  /**
   * Return an instance with the specified status code and, optionally, reason phrase.
   *
   * @link http://tools.ietf.org/html/rfc7231#section-6
   * @link http://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml
   *
   * @throws Exception\InvalidArgumentException For invalid status code arguments.
   */
  public function withStatus(int $code, string $reasonPhrase = ''): this {
    $this->assertValidStatusCode($code);
    $new = clone $this;
    $new->statusCode = $code;

    if (
      '' === $reasonPhrase && C\contains_key(self::$phrases, $new->statusCode)
    ) {
      $reasonPhrase = self::$phrases[$new->statusCode];
    }

    $new->reasonPhrase = '' === $reasonPhrase ? null : $reasonPhrase;

    return $new;
  }

  /**
   * Gets the response reason phrase associated with the status code.
   *
   * Because a reason phrase is not a required element in a response
   * status line, the reason phrase value MAY be null.
   *
   * @link http://tools.ietf.org/html/rfc7231#section-6
   * @link http://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml
   */
  public function getReasonPhrase(): ?string {
    return $this->reasonPhrase ?? static::$phrases[$this->statusCode] ?? null;
  }

  /**
   * Retrieve all cookies associated with the response.
   */
  public function getCookies(): KeyedContainer<string, Message\ICookie> {
    return $this->cookies;
  }

  /**
   * Retrieves a response cookie by the given case-sensitive name.
   *
   * This method returns a cookie instance of the given
   * case-sensitive cookie name.
   *
   * If the cookie does not appear in the response, this method will return null.
   */
  public function getCookie(string $name): ?Message\ICookie {
    return $this->cookies[$name] ?? null;
  }

  /**
   * Return an instance with the provided Cookie.
   *
   * @link https://tools.ietf.org/html/rfc6265#section-4.1
   */
  public function withCookie(string $name, Message\ICookie $cookie): this {
    $new = clone $this;
    $new->cookies[$name] = $cookie;
    return $new;
  }

  /**
   * Return an instance without the specified cookie.
   */
  public function withoutCookie(string $name): this {
    if (!C\contains_key($this->cookies, $name)) {
      return $this;
    }

    $new = clone $this;
    unset($new->cookies[$name]);
    return $new;
  }

  /**
   * Gets the body of the message.
   */
  <<__Override>>
  public function getBody(): IO\SeekableReadWriteHandle {
    if ($this->body is null) {
      $this->body = Body\memory();
    }

    return $this->body;
  }

  private function assertValidStatusCode(int $code): void {
    if ($code < 100 || $code > 599) {
      throw new Exception\InvalidArgumentException(
        'Status code has to be an integer between 100 and 599',
      );
    }
  }
}
