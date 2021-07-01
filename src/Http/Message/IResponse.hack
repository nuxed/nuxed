/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Message;

use namespace HH\Lib\IO;

/**
 * Representation of an outgoing, server-side response.
 *
 * Per the HTTP specification, this interface includes properties for
 * each of the following:
 *
 * - Protocol version
 * - Status code and reason phrase
 * - Headers
 *   - Cookies
 * - Message body
 *
 * Responses are considered immutable; all methods that might change state MUST
 * be implemented such that they retain the internal state of the current
 * message and return an instance that contains the changed state.
 */
interface IResponse extends IMessage<IO\SeekableReadWriteHandle> {
  /**
   * Gets the response status code.
   *
   * The status code is a 3-digit integer result code of the server's attempt
   * to understand and satisfy the request.
   */
  public function getStatusCode(): int;

  /**
   * Return an instance with the specified status code and, optionally, reason phrase.
   *
   * If no reason phrase is specified, implementations MAY choose to default
   * to the RFC 7231 or IANA recommended reason phrase for the response's
   * status code.
   *
   * This method MUST be implemented in such a way as to retain the
   * immutability of the message, and MUST return an instance that has the
   * updated status and reason phrase.
   *
   * @link http://tools.ietf.org/html/rfc7231#section-6
   * @link http://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml
   *
   * @throws Exception\IException For invalid status code arguments.
   */
  public function withStatus(int $code, string $reasonPhrase = ''): this;

  /**
   * Gets the response reason phrase associated with the status code.
   *
   * Because a reason phrase is not a required element in a response
   * status line, the reason phrase value MAY be null. Implementations MAY
   * choose to return the default RFC 7231 recommended reason phrase (or those
   * listed in the IANA HTTP Status Code Registry) for the response's
   * status code.
   *
   * @link http://tools.ietf.org/html/rfc7231#section-6
   * @link http://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml
   */
  public function getReasonPhrase(): ?string;

  /**
   * Retrieve all cookies associated with the response.
   */
  public function getCookies(): KeyedContainer<string, ICookie>;

  /**
   * Retrieves a response cookie by the given case-sensitive name.
   *
   * This method returns a cookie instance of the given
   * case-sensitive cookie name.
   *
   * If the cookie does not appear in the response, this method MUST return null.
   */
  public function getCookie(string $name): ?ICookie;

  /**
   * Return an instance with the provided Cookie.
   *
   * This method MUST be implemented in such a way as to retain the
   * immutability of the message, and MUST return an instance that has the
   * changed response cookies.
   *
   * @link https://tools.ietf.org/html/rfc6265#section-4.1
   */
  public function withCookie(string $name, ICookie $cookie): this;

  /**
   * Return an instance without the specified cookie.
   *
   * Cookie name resolution MUST be done with case-sensitivity.
   *
   * This method MUST be implemented in such a way as to retain the
   * immutability of the message, and MUST return an instance that removes
   * the named cookie.
   */
  public function withoutCookie(string $name): this;
}
