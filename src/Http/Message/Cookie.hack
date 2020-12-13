namespace Nuxed\Http\Message;

use namespace Nuxed\Http\Message;

/**
 * Value object representing a response cookie.
 *
 * @link https://tools.ietf.org/html/rfc6265#section-4.1 (HTTP State Management Mechanism)
 * @link https://tools.ietf.org/html/draft-west-first-party-cookies-07 (Same-Site Attribute)
 */
final class Cookie implements Message\ICookie {
  public function __construct(
    private string $value,
    private ?int $expires = null,
    private ?int $maxAge = null,
    private ?string $path = null,
    private ?string $domain = null,
    private ?bool $secure = null,
    private ?bool $httpOnly = null,
    private ?Message\CookieSameSite $sameSite = null,
  ) {}

  /**
   * Retrieve the expires attribute of the cookie.
   *
   * If the attribute is present, this method MUST return null.
   */
  public function getValue(): string {
    return $this->value;
  }

  /**
   * Retrieve the max-age attribute of the cookie.
   *
   * If the attribute is not present, this method MUST return null.
   */
  public function getExpires(): ?int {
    return $this->expires;
  }

  /**
   * Retrieve the max-age attribute of the cookie.
   *
   * If the attribute is not present, this method MUST return null.
   */
  public function getMaxAge(): ?int {
    return $this->maxAge;
  }

  /**
   * Retrieve the path attribute of the cookie.
   *
   * If the attribute is not present, this method MUST return null.
   */
  public function getPath(): ?string {
    return $this->path;
  }

  /**
   * Retrieve the domain attribute of the cookie.
   *
   * If the attribute is not present, this method MUST return null.
   */
  public function getDomain(): ?string {
    return $this->domain;
  }

  /**
   * Retrieve the secure attribute of the cookie.
   *
   * If the attribute is not present, this method MUST return null.
   */
  public function getSecure(): ?bool {
    return $this->secure;
  }

  /**
   * Retrieve the http-only attribute of the cookie.
   *
   * If the attribute is not present, this method MUST return null.
   */
  public function getHttpOnly(): ?bool {
    return $this->httpOnly;
  }

  /**
   * Retrieve the same-site attribute of the cookie.
   *
   * If the attribute is not present, this method MUST return null.
   */
  public function getSameSite(): ?Message\CookieSameSite {
    return $this->sameSite;
  }

  /**
   * This method MUST retain the state of the current instance, and return
   * an instance that contains the specified value.
   *
   * Users can provide both encoded and decoded value characters.
   * Implementations ensure the correct encoding as outlined in getValue().
   */
  public function withValue(string $value): this {
    $new = clone $this;
    $new->value = $value;

    return $new;
  }

  /**
   * This method MUST retain the state of the current instance, and return
   * an instance that contains the specified `expires` attribute value.
   *
   * A null value provided is equivalent to removing the `expires`
   * attribute.
   */
  public function withExpires(?int $expires): this {
    $new = clone $this;
    $new->expires = $expires;

    return $new;
  }

  /**
   * This method MUST retain the state of the current instance, and return
   * an instance that contains the specified `max-age` attribute value.
   *
   * A null value provided is equivalent to removing the `max-age`
   * attribute.
   *
   * Providing zero or negative value will make the cookie expired immediately.
   */
  public function withMaxAge(?int $maxAge): this {
    $new = clone $this;
    $new->maxAge = $maxAge;

    return $new;
  }

  /**
   * This method MUST retain the state of the current instance, and return
   * an instance that contains the specified `path` attribute value.
   *
   * A null value provided is equivalent to removing the `path`
   * attribute.
   */
  public function withPath(?string $path): this {
    $new = clone $this;
    $new->path = $path;

    return $new;
  }

  /**
   * This method MUST retain the state of the current instance, and return
   * an instance that contains the specified `domain` attribute value.
   *
   * A null value provided is equivalent to removing the `domain`
   * attribute.
   */
  public function withDomain(?string $domain): this {
    $new = clone $this;
    $new->domain = $domain;

    return $new;
  }

  /**
   * This method retains the state of the current instance, and return
   * an instance that contains the specified `secure` attribute value.
   */
  public function withSecure(bool $secure = true): this {
    $new = clone $this;
    $new->secure = $secure;

    return $new;
  }

  /**
   * This method MUST retain the state of the current instance, and return
   * an instance that contains the specified `http-only` attribute value.
   */
  public function withHttpOnly(bool $httpOnly = true): this {
    $new = clone $this;
    $new->httpOnly = $httpOnly;

    return $new;
  }

  /**
   * This method MUST retain the state of the current instance, and return
   * an instance that contains the specified `same-site` attribute value.
   *
   * A null value provided is equivalent to removing the `same-site`
   * attribute.
   */
  public function withSameSite(?Message\CookieSameSite $sameSite): this {
    $new = clone $this;
    $new->sameSite = $sameSite;

    return $new;
  }

  /**
   * This method MUST retain the state of the current instance, and return
   * an instance that does not contain the `secure` attribute.
   */
  public function withoutSecure(): this {
    $new = clone $this;
    $new->secure = null;

    return $new;
  }

  /**
   * This method MUST retain the state of the current instance, and return
   * an instance that does not contain the `http-only` attribute.
   */
  public function withoutHttpOnly(): this {
    $new = clone $this;
    $new->httpOnly = null;

    return $new;
  }
}
