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
 * HTTP messages consist of requests from a client to a server and responses
 * from a server to a client. This interface defines the methods common to
 * each.
 *
 * Messages are considered immutable; all methods that might change state MUST
 * be implemented such that they retain the internal state of the current
 * message and return an instance that contains the changed state.
 *
 * @link http://www.ietf.org/rfc/rfc7230.txt
 * @link http://www.ietf.org/rfc/rfc7231.txt
 */
interface IMessage<T as IO\SeekableHandle> {
  /**
   * Retrieves the HTTP protocol version as a string.
   *
   * The string MUST contain only the HTTP version number (e.g., "1.1", "1.0").
   */
  public function getProtocolVersion(): string;

  /**
   * Return an instance with the specified HTTP protocol version.
   *
   * The version string MUST contain only the HTTP version number (e.g.,
   * "1.1", "1.0").
   *
   * This method MUST be implemented in such a way as to retain the
   * immutability of the message, and MUST return an instance that has the
   * new protocol version.
   */
  public function withProtocolVersion(string $version): this;

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
  public function getHeaders(): KeyedContainer<string, Container<string>>;

  /**
   * Checks if a header exists by the given case-insensitive name.
   *
   * @return bool Returns true if any header names match the given header
   *     name using a case-insensitive string comparison. Returns false if
   *     no matching header name is found in the message.
   */
  public function hasHeader(string $header): bool;

  /**
   * Retrieves a message header value by the given case-insensitive name.
   *
   * This method returns a container of all the header values of the given
   * case-insensitive header name.
   *
   * If the header does not appear in the message, this method MUST return an
   * empty container.
   */
  public function getHeader(string $header): Container<string>;

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
   * If the header does not appear in the message, this method MUST return
   * an empty string.
   */
  public function getHeaderLine(string $header): string;

  /**
   * Return an instance with the provided value replacing the specified header.
   *
   * While header names are case-insensitive, the casing of the header will
   * be preserved by this function, and returned from getHeaders().
   *
   * This method MUST be implemented in such a way as to retain the
   * immutability of the message, and MUST return an instance that has the
   * new and/or updated header and value.
   *
   * @throws Exception\IException for invalid header names or values.
   */
  public function withHeader(string $header, Container<string> $value): this;

  /**
   * Return an instance with the specified header appended with the given value.
   *
   * Existing values for the specified header will be maintained. The new
   * value(s) will be appended to the existing list. If the header did not
   * exist previously, it will be added.
   *
   * This method MUST be implemented in such a way as to retain the
   * immutability of the message, and MUST return an instance that has the
   * new header and/or value.
   *
   * @throws Exception\IException for invalid header names or values.
   */
  public function withAddedHeader(
    string $header,
    Container<string> $value,
  ): this;

  /**
   * Return an instance without the specified header.
   *
   * Header resolution MUST be done without case-sensitivity.
   *
   * This method MUST be implemented in such a way as to retain the
   * immutability of the message, and MUST return an instance that removes
   * the named header.
   */
  public function withoutHeader(string $header): this;

  /**
   * Gets the body of the message.
   */
  public function getBody(): T;

  /**
   * Return an instance with the specified message body.
   *
   * The body MUST be an IO\SeekableHandle object.
   *
   * This method MUST be implemented in such a way as to retain the
   * immutability of the message, and MUST return a new instance that has the
   * new body handle.
   *
   * @throws Exception\IException When the body is not valid.
   */
  public function withBody(T $body): this;
}
