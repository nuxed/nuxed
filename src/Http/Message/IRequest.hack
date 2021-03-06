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
 * Representation of an outgoing, client-side request.
 *
 * Per the HTTP specification, this interface includes properties for
 * each of the following:
 *
 * - Protocol version
 * - HTTP method
 * - URI
 * - Headers
 * - Message body
 *
 * During construction, implementations MUST attempt to set the Host header from
 * a provided URI if no Host header is provided.
 *
 * Requests are considered immutable; all methods that might change state MUST
 * be implemented such that they retain the internal state of the current
 * message and return an instance that contains the changed state.
 */
interface IRequest extends IMessage<IO\SeekableReadHandle> {
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
   * provided, this method MUST return the string "/".
   */
  public function getRequestTarget(): string;

  /**
   * Return an instance with the specific request-target.
   *
   * If the request needs a non-origin-form request-target — e.g., for
   * specifying an absolute-form, authority-form, or asterisk-form —
   * this method may be used to create an instance with the specified
   * request-target, verbatim.
   *
   * This method MUST be implemented in such a way as to retain the
   * immutability of the message, and MUST return an instance that has the
   * changed request target.
   *
   * @link http://tools.ietf.org/html/rfc7230#section-5.3 (for the various
   *     request-target forms allowed in request messages)
   */
  public function withRequestTarget(string $request_target): this;

  /**
   * Retrieves the HTTP method of the request.
   */
  public function getMethod(): HttpMethod;

  /**
   * Return an instance with the provided HTTP method.
   *
   * This method MUST be implemented in such a way as to retain the
   * immutability of the message, and MUST return an instance that has the
   * changed request method.
   *
   * @throws Exception\IException for invalid HTTP methods.
   */
  public function withMethod(HttpMethod $method): this;

  /**
   * Retrieves the URI instance.
   *
   * @link http://tools.ietf.org/html/rfc3986#section-4.3
   */
  public function getUri(): IUri;

  /**
   * Returns an instance with the provided URI.
   *
   * This method MUST update the Host header of the returned request by
   * default if the URI contains a host component. If the URI does not
   * contain a host component, any pre-existing Host header MUST be carried
   * over to the returned request.
   *
   * You can opt-in to preserving the original state of the Host header by
   * setting `$preserve_host` to `true`. When `$preserve_host` is set to
   * `true`, this method interacts with the Host header in the following ways:
   *
   * - If the Host header is missing or empty, and the new URI contains
   *   a host component, this method MUST update the Host header in the returned
   *   request.
   * - If the Host header is missing or empty, and the new URI does not contain a
   *   host component, this method MUST NOT update the Host header in the returned
   *   request.
   * - If a Host header is present and non-empty, this method MUST NOT update
   *   the Host header in the returned request.
   *
   * This method MUST be implemented in such a way as to retain the
   * immutability of the message, and MUST return an instance that has the
   * new UriInterface instance.
   *
   * @link http://tools.ietf.org/html/rfc3986#section-4.3
   */
  public function withUri(IUri $uri, bool $preserve_host = false): this;
}
