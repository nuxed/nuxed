namespace Nuxed\Http\Message;

/**
 * Value object representing a response cookie.
 *
 * This interface is meant to represent cookies according to RFC 6265 section 4.1 and to
 * provide methods for most common operations. Additional functionality for
 * working with cookies can be provided on top of the interface or externally.
 *
 * Instances of this interface are considered immutable; all methods that
 * might change state MUST be implemented such that they retain the internal
 * state of the current instance and return an instance that contains the
 * changed state.
 *
 * @link https://tools.ietf.org/html/rfc6265#section-4.1 (HTTP State Management Mechanism)
 * @link https://tools.ietf.org/html/draft-west-first-party-cookies-07 (Same-Site Attribute)
 */
interface ICookie {

  /**
   * Retrieve the value of the cookie.
   *
   * If no value is present, this method MUST return an empty string.
   */
  public function getValue(): string;

  /**
   * Retrieve the expires attribute of the cookie.
   *
   * If the attribute is not present, this method MUST return null.
   */
  public function getExpires(): ?int;

  /**
   * Retrieve the max-age attribute of the cookie.
   *
   * If the attribute is not present, this method MUST return null.
   */
  public function getMaxAge(): ?int;

  /**
   * Retrieve the path attribute of the cookie.
   *
   * If the attribute is not present, this method MUST return null.
   */
  public function getPath(): ?string;

  /**
   * Retrieve the domain attribute of the cookie.
   *
   * If the attribute is not present, this method MUST return null.
   */
  public function getDomain(): ?string;

  /**
   * Retrieve the secure attribute of the cookie.
   *
   * If the attribute is not present, this method MUST return null.
   */
  public function getSecure(): ?bool;

  /**
   * Retrieve the http-only attribute of the cookie.
   *
   * If the attribute is not present, this method MUST return null.
   */
  public function getHttpOnly(): ?bool;

  /**
   * Retrieve the same-site attribute of the cookie.
   *
   * If the attribute is not present, this method MUST return null.
   */
  public function getSameSite(): ?CookieSameSite;

  /**
   * This method MUST retain the state of the current instance, and return
   * an instance that contains the specified value.
   *
   * Users can provide both encoded and decoded value characters.
   * Implementations ensure the correct encoding as outlined in getValue().
   */
  public function withValue(string $value): this;

  /**
   * This method MUST retain the state of the current instance, and return
   * an instance that contains the specified `expires` attribute value.
   *
   * A null value provided is equivalent to removing the `expires`
   * attribute.
   */
  public function withExpires(?int $expires): this;

  /**
   * This method MUST retain the state of the current instance, and return
   * an instance that contains the specified `max-age` attribute value.
   *
   * A null value provided is equivalent to removing the `max-age`
   * attribute.
   *
   * Providing zero or negative value will make the cookie expired immediately.
   */
  public function withMaxAge(?int $maxage): this;

  /**
   * This method MUST retain the state of the current instance, and return
   * an instance that contains the specified `path` attribute value.
   *
   * A null value provided is equivalent to removing the `path`
   * attribute.
   */
  public function withPath(?string $path): this;

  /**
   * This method MUST retain the state of the current instance, and return
   * an instance that contains the specified `domain` attribute value.
   *
   * A null value provided is equivalent to removing the `domain`
   * attribute.
   */
  public function withDomain(?string $domain): this;

  /**
   * This method MUST retain the state of the current instance, and return
   * an instance that contains the specified `secure` attribute value.
   */
  public function withSecure(bool $secure = true): this;

  /**
   * This method MUST retain the state of the current instance, and return
   * an instance that contains the specified `http-only` attribute value.
   */
  public function withHttpOnly(bool $httpOnly = true): this;

  /**
   * This method MUST retain the state of the current instance, and return
   * an instance that contains the specified `same-site` attribute value.
   *
   * A null value provided is equivalent to removing the `same-site`
   * attribute.
   */
  public function withSameSite(?CookieSameSite $sameSite): this;

  /**
   * This method MUST retain the state of the current instance, and return
   * an instance that does not contain the `secure` attribute.
   */
  public function withoutSecure(): this;

  /**
   * This method MUST retain the state of the current instance, and return
   * an instance that does not contain the `http-only` attribute.
   */
  public function withoutHttpOnly(): this;
}
