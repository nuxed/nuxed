namespace Nuxed\Http\Message;

use namespace HH\Lib\{C, Dict, IO};
use namespace Nuxed\Http\{Flash, Message, Session};

final class ServerRequest extends Request implements Message\IServerRequest {
  private dict<string, mixed> $attributes = dict[];

  private KeyedContainer<string, string> $serverParams = dict[];
  private KeyedContainer<string, string> $cookieParams = dict[];
  private KeyedContainer<string, string> $queryParams = dict[];

  private ?KeyedContainer<string, string> $parsedBody = null;

  private KeyedContainer<string, Message\IUploadedFile> $uploadedFiles = dict[];

  private ?Session\ISession $session = null;
  private ?Flash\IFlashMessages $flash = null;

  public function __construct(
    HttpMethod $method,
    Message\IUri $uri,
    KeyedContainer<string, Container<string>> $headers = dict[],
    ?IO\SeekableReadWriteHandle $body = null,
    string $version = '1.1',
    KeyedContainer<string, string> $serverParams = dict[],
  ) {
    $this->method = $method;
    $this->uri = $uri;
    $this->serverParams = $serverParams;
    parent::__construct($method, $uri, $headers, $body, $version);
  }

  <<__Override>>
  public function __clone(): void {
    parent::__clone();
    $this->session = $this->session is nonnull ? clone $this->session : null;
    $this->flash = $this->flash is nonnull ? clone $this->flash : null;
    $this->uploadedFiles = Dict\map(
      $this->uploadedFiles,
      (Message\IUploadedFile $file): Message\IUploadedFile ==> clone $file,
    );
  }

  /**
   * Create a new Http Server Request Message from the global variables.
   */
  public static async function capture(): Awaitable<ServerRequest> {
    return await _Private\create_server_request_from_globals();
  }

  /**
   * Retrieve server parameters.
   *
   * Retrieves data related to the incoming request environment.
   */
  public function getServerParams(): KeyedContainer<string, string> {
    /* HH_IGNORE_ERROR[4110] */
    return $this->serverParams;
  }

  /**
   * Retrieve cookies.
   *
   * Retrieves cookies sent by the client to the server.
   */
  public function getCookieParams(): KeyedContainer<string, string> {
    return $this->cookieParams;
  }

  /**
   * Return an instance with the specified cookies.
   *
   * This method DOES NOT update the related Cookie header of the request
   * instance, nor related values in the server params.
   */
  public function withCookieParams(
    KeyedContainer<string, string> $cookies,
  ): this {
    $new = clone $this;
    $new->cookieParams = $cookies;

    return $new;
  }

  /**
   * Retrieve query string arguments.
   *
   * Retrieves the deserialized query string arguments, if any.
   *
   * Note: the query params might not be in sync with the URI or server
   * params. If you need to ensure you are only getting the original
   * values, you may need to parse the query string from `getUri()->getQuery()`
   */
  public function getQueryParams(): KeyedContainer<string, string> {
    return $this->queryParams;
  }

  /**
   * Return an instance with the specified query string arguments.
   *
   * Setting query string arguments DOES NOT change the URI stored by the
   * request, nor the values in the server params.
   */
  public function withQueryParams(KeyedContainer<string, string> $query): this {
    $new = clone $this;
    $new->queryParams = $query;

    return $new;
  }

  /**
   * Retrieve normalized file upload data.
   *
   * These values MAY be prepared from the message body during
   * instantiation, or MAY be injected via withUploadedFiles().
   */
  public function getUploadedFiles(
  ): KeyedContainer<string, Message\IUploadedFile> {
    return $this->uploadedFiles;
  }

  /**
   * Create a new instance with the specified uploaded files.
   */
  public function withUploadedFiles(
    KeyedContainer<string, Message\IUploadedFile> $uploadedFiles,
  ): this {
    $new = clone $this;
    $new->uploadedFiles = $uploadedFiles;

    return $new;
  }

  /**
   * Retrieve any parameters provided in the request body.
   *
   * If the request Content-Type is either application/x-www-form-urlencoded
   * or multipart/form-data, and the request method is POST, this method will
   * return the contents of the form submitted.
   *
   * Otherwise, this method may return any results of deserializing
   * the request body content;
   */
  public function getParsedBody(): ?KeyedContainer<string, string> {
    return $this->parsedBody;
  }

  /**
   * Return an instance with the specified body parameters.
   *
   * These MAY be injected during instantiation.
   *
   * If the request Content-Type is either application/x-www-form-urlencoded
   * or multipart/form-data, and the request method is POST, use this method
   * ONLY to inject the contents of the submitted form.
   *
   * The data IS NOT REQUIRED to come from a submitted form, but MUST be the results of
   * deserializing the request body content. Deserialization/parsing returns
   * structured data, and, as such, this method ONLY accepts keyed containers,
   * or a null value if nothing was available to parse.
   *
   * As an example, if content negotiation determines that the request data
   * is a JSON payload, this method could be used to create a request
   * instance with the deserialized parameters.
   */
  public function withParsedBody(
    ?KeyedContainer<string, string> $parsedBody,
  ): this {
    $new = clone $this;
    $new->parsedBody = $parsedBody;

    return $new;
  }

  /**
   * Retrieve attributes derived from the request.
   *
   * The request "attributes" may be used to allow injection of any
   * parameters derived from the request: e.g., the results of path
   * match operations; the results of decrypting cookies; the results of
   * deserializing non-form-encoded message bodies; etc. Attributes
   * will be application and request specific, and CAN be mutable.
   */
  public function getAttributes<<<__Enforceable>> reify T>(
  ): KeyedContainer<string, T> {
    $attributes = dict[];
    foreach ($this->attributes as $key => $value) {
      $attributes[$key] = $value as T;
    }

    return $attributes;
  }

  /**
   * Whether the request contains a specific attribute.
   */
  public function hasAttribute(string $key): bool {
    return C\contains_key($this->attributes, $key);
  }

  /**
   * Retrieve a single derived request attribute.
   *
   * Retrieves a single derived request attribute as described in
   * getAttributes(). If the attribute has not been previously set, returns
   * the default value as provided.
   *
   * This method obviates the need for a hasAttribute() method, as it allows
   * specifying a default value to return if the attribute is not found.
   *
   * @see getAttributes()
   */
  public function getAttribute<<<__Enforceable>> reify T>(string $key): T {
    invariant($this->hasAttribute($key), 'Invalid attribute key.');

    return $this->attributes[$key] as T;
  }

  /**
   * Return an instance with the specified derived request attribute.
   *
   * This method allows setting a single derived request attribute as
   * described in getAttributes().
   *
   * @see getAttributes()
   */
  public function withAttribute<<<__Enforceable>> reify T>(
    string $attribute,
    T $value,
  ): this {
    $new = clone $this;
    $new->attributes[$attribute] = $value;
    return $new;
  }

  /**
   * Return an instance that removes the specified derived request attribute.
   *
   * This method allows removing a single derived request attribute as
   * described in getAttributes().
   *
   * @see getAttributes()
   */
  public function withoutAttribute(string $attribute): this {
    if (!C\contains_key($this->attributes, $attribute)) {
      return $this;
    }

    $new = clone $this;
    unset($new->attributes[$attribute]);

    return $new;
  }

  /**
   * Return an instance with the specified session implementation.
   */
  public function withSession(Session\ISession $session): this {
    $clone = clone $this;
    $clone->session = $session;
    return $clone;
  }

  /**
   * Whether the request contains a Session object.
   *
   * This method does not give any information about the state of the session object,
   * like whether the session is started or not. It is just a way to check if this request
   * is associated with a session instance.
   *
   * @see setSession()
   * @see getSession()
   */
  public function hasSession(): bool {
    return $this->session is nonnull;
  }

  /**
   * Gets the body of the message.
   *
   * @see hasSession()
   * @see setSession()
   */
  public function getSession(): Session\ISession {
    return $this->session as nonnull;
  }

  /**
   * Return an instance with the specified flash implementation.
   */
  public function withFlash(Flash\IFlashMessages $flash): this {
    $clone = clone $this;
    $clone->flash = $flash;
    return $clone;
  }

  /**
   * Whether the request contains a flash object.
   *
   * @see setFlash()
   * @see getFlash()
   */
  public function hasFlash(): bool {
    return $this->flash is nonnull;
  }

  /**
   * Gets the body of the message.
   *
   * @see hasFlash()
   * @see setFlash()
   */
  public function getFlash(): Flash\IFlashMessages {
    return $this->flash as nonnull;
  }
}
