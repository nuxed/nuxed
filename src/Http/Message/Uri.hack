namespace Nuxed\Http\Message;

use namespace HH\Lib\{C, Regex, Str};
use namespace Nuxed\Http\{Exception, Message};

/**
 * Value object representing a URI.
 *
 * This class is meant to represent URIs according to RFC 3986 and to
 * provide methods for most common operations.
 *
 * Instances of this class are considered immutable; all methods that
 * might change state are implemented such that they retain the internal
 * state of the current instance and return an instance that contains the
 * changed state.
 *
 * Typically the Host header will be also be present in the request message.
 * For server-side requests, the scheme will typically be discoverable in the
 * server parameters.
 *
 * @link http://tools.ietf.org/html/rfc3986 (the URI specification)
 */
final class Uri implements Message\IUri {
  private static dict<string, int> $schemes = dict[
    'http' => 80,
    'https' => 443,
  ];

  private ?string $scheme = null;

  private ?string $userInfo = null;

  private ?string $host = null;

  private ?int $port = null;

  private string $path = '';

  private ?string $query = null;

  private ?string $fragment = null;

  public function __construct(string $uri = '') {
    if ('' !== $uri) {
      $parts = \parse_url($uri);

      if (false === $parts) {
        throw new Exception\InvalidArgumentException(
          'Unable to parse URI: '.$uri,
        );
      }

      $this->applyParts(dict($parts));
    }
  }

  public function toString(): string {
    $uri = '';

    if ($this->scheme is nonnull && '' !== $this->scheme) {
      $uri .= $this->scheme.':';
    }

    $authority = $this->getAuthority();
    if ($authority is nonnull && '' !== $authority) {
      $uri .= '//'.$authority;
    }

    $path = $this->path;
    if (Str\length($path) > 0) {
      if ('/' !== $path[0]) {
        if ($authority is nonnull && '' !== $authority) {
          // If the path is rootless and an authority is present, the path will be prefixed by "/"
          $path = '/'.$path;
        }
      } else if (Str\length($path) > 1 && '/' === $path[1]) {
        if ($authority is null || '' === $authority) {
          // If the path is starting with more than one "/" and no authority is present, the
          // starting slashes will be reduced to one.
          $path = '/'.Str\trim_left($path, '/');
        }
      }

      $uri .= $path;
    }

    if ($this->query is nonnull && '' !== $this->query) {
      $uri .= '?'.$this->query;
    }

    if ($this->fragment is nonnull && '' !== $this->fragment) {
      $uri .= '#'.$this->fragment;
    }

    return $uri;
  }

  /**
   * Retrieve the scheme component of the URI.
   *
   * If no scheme is present, this method will return a null.
   *
   * The value returned will be normalized to lowercase, per RFC 3986
   * Section 3.1.
   *
   * @see https://tools.ietf.org/html/rfc3986#section-3.1
   */
  public function getScheme(): ?string {
    return $this->scheme;
  }

  /**
   * Retrieve the authority component of the URI.
   *
   * If no authority information is present, this method will null.
   *
   * The authority syntax of the URI is:
   *
   * <pre>
   *  [user-info@]host[:port]
   * </pre>
   *
   * If the port component is not set or is the standard port for the current
   * scheme, it will not be included.
   *
   * @see https://tools.ietf.org/html/rfc3986#section-3.2
   */
  public function getAuthority(): ?string {
    if ($this->host is null || '' === $this->host) {
      return null;
    }

    $authority = $this->host;

    if ($this->userInfo is nonnull && '' !== $this->userInfo) {
      $authority = Str\format('%s@%s', $this->userInfo, $authority);
    }

    if ($this->port is nonnull) {
      $authority = Str\format('%s:%d', $authority, $this->port);
    }

    return $authority;
  }

  /**
   * Retrieve the user information component of the URI.
   *
   * If no user information is present, this method MUST return null.
   *
   * If a user is present in the URI, this will return that value;
   * additionally, if the password is also present, it will be appended to the
   * user value, with a colon (":") separating the values.
   *
   * @return string The URI user information, in "username[:password]" format.
   */
  public function getUserInfo(): ?string {
    return $this->userInfo;
  }

  /**
   * Retrieve the host component of the URI.
   *
   * If no host is present, this method MUST return null.
   *
   * The value returned will be normalized to lowercase, per RFC 3986
   * Section 3.2.2.
   *
   * @see http://tools.ietf.org/html/rfc3986#section-3.2.2
   */
  public function getHost(): ?string {
    return $this->host;
  }

  /**
   * Retrieve the port component of the URI.
   *
   * If a port is present, and it is non-standard for the current scheme,
   * this method will return it as an integer. If the port is the standard port
   * used with the current scheme, this method will return null.
   *
   * If no port is present, and no scheme is present, this method will return
   * a null value.
   */
  public function getPort(): ?int {
    return $this->port;
  }

  /**
   * Retrieve the path component of the URI.
   *
   * The path can either be empty or absolute (starting with a slash) or
   * rootless (not starting with a slash).
   *
   * Normally, the empty path "" and absolute path "/" are considered equal as
   * defined in RFC 7230 Section 2.7.3. But this method will not automatically
   * do this normalization because in contexts with a trimmed base path, e.g.
   * the front controller, this difference becomes significant. It's the task
   * of the user to handle both "" and "/".
   *
   * As an example, if the value should include a slash ("/") not intended as
   * delimiter between path segments, that value MUST be passed in encoded
   * form (e.g., "%2F") to the instance.
   *
   * @see https://tools.ietf.org/html/rfc3986#section-2
   * @see https://tools.ietf.org/html/rfc3986#section-3.3
   */
  public function getPath(): string {
    return $this->path;
  }

  /**
   * Retrieve the query string of the URI.
   *
   * If no query string is present, this method MUST return null.
   *
   * @see https://tools.ietf.org/html/rfc3986#section-2
   * @see https://tools.ietf.org/html/rfc3986#section-3.4
   */
  public function getQuery(): ?string {
    return $this->query;
  }

  /**
   * Retrieve the fragment component of the URI.
   *
   * If no fragment is present, this method MUST return null.
   *
   * @see https://tools.ietf.org/html/rfc3986#section-2
   * @see https://tools.ietf.org/html/rfc3986#section-3.5
   */
  public function getFragment(): ?string {
    return $this->fragment;
  }

  /**
   * Return an instance with the specified scheme.
   *
   * This method will retain the state of the current instance, and return
   * an instance that contains the specified scheme.
   *
   * A null value provided for the schema is equivalent to removing the scheme.
   */
  public function withScheme(?string $scheme): this {
    $scheme = $scheme is nonnull ? Str\lowercase($scheme) : $scheme;

    if ($this->scheme === $scheme) {
      return $this;
    }

    $new = clone $this;
    $new->scheme = $scheme;
    $new->port = $new->filterPort($new->port);

    return $new;
  }

  /**
   * Return an instance with the specified user information.
   *
   * This method retains the state of the current instance, and return
   * an instance that contains the specified user information.
   *
   * Password is optional, but the user information MUST include the
   * user; a null value provided for the user is equivalent to removing user
   * information.
   */
  public function withUserInfo(?string $user, ?string $password = null): this {
    $info = null;
    if ($user is nonnull && '' !== $user) {
      $info = $user;
      if ($password is nonnull && '' !== $password) {
        $info .= ':'.$password;
      }
    }

    if ($this->userInfo === $info) {
      return $this;
    }

    $new = clone $this;
    $new->userInfo = $info;

    return $new;
  }

  /**
   * Return an instance with the specified host.
   *
   * A null host value is equivalent to removing the host.
   */
  public function withHost(?string $host): this {
    $host = $host is nonnull ? Str\lowercase($host) : null;

    if ($this->host === $host) {
      return $this;
    }

    $new = clone $this;
    $new->host = $host;

    return $new;
  }

  /**
   * Return an instance with the specified port.
   *
   * A null value provided for the port is equivalent to removing the port
   * information.
   *
   * @throws Exception\InvalidArgumentException for ports outside the
   *  established TCP and UDP port ranges.
   */
  public function withPort(?int $port): this {
    $port = $this->filterPort($port);

    if ($this->port === $port) {
      return $this;
    }

    $new = clone $this;
    $new->port = $port;

    return $new;
  }

  /**
   * Return an instance with the specified path.
   *
   * The path can either be empty or absolute (starting with a slash) or
   * rootless (not starting with a slash).
   *
   * If the path is intended to be domain-relative rather than path relative then
   * it must begin with a slash ("/"). Paths not starting with a slash ("/")
   * are assumed to be relative to some base path known to the application or
   * consumer.
   */
  public function withPath(string $path): this {
    $path = $this->filterPath($path);

    if ($this->path === $path) {
      return $this;
    }

    $new = clone $this;
    $new->path = $path;

    return $new;
  }

  /**
   * Return an instance with the specified query string.
   *
   * A null query string value is equivalent to removing the query string.
   */
  public function withQuery(?string $query): this {
    $query = $this->filterQueryAndFragment($query);
    if ($this->query === $query) {
      return $this;
    }

    $new = clone $this;
    $new->query = $query;

    return $new;
  }

  /**
   * Return an instance with the specified URI fragment.
   *
   * A null fragment value is equivalent to removing the fragment.
   */
  public function withFragment(?string $fragment): this {
    $fragment = $this->filterQueryAndFragment($fragment);

    if ($this->fragment === $fragment) {
      return $this;
    }

    $new = clone $this;
    $new->fragment = $fragment;

    return $new;
  }

  /**
   * Apply parse_url parts to a URI.
   */
  private function applyParts(KeyedContainer<string, arraykey> $parts): void {
    $this->scheme = C\contains_key($parts, 'scheme')
      ? Str\lowercase((string)$parts['scheme'])
      : null;

    $this->host = C\contains_key($parts, 'host')
      ? Str\lowercase((string)$parts['host'])
      : null;

    $this->port = C\contains_key($parts, 'port')
      ? $this->filterPort((int)$parts['port'])
      : null;

    $this->path = C\contains_key($parts, 'path')
      ? $this->filterPath((string)$parts['path'])
      : '';

    $this->query = C\contains_key($parts, 'query')
      ? $this->filterQueryAndFragment((string)$parts['query'])
      : null;

    $this->fragment = C\contains_key($parts, 'fragment')
      ? $this->filterQueryAndFragment((string)$parts['fragment'])
      : null;

    if (C\contains_key($parts, 'user')) {
      $this->userInfo = (string)$parts['user'];

      if (C\contains_key($parts, 'pass')) {
        $this->userInfo = (string)$parts['user'].':'.(string)$parts['pass'];
      }

    } else {
      $this->userInfo = null;
    }
  }

  /**
   * Is a given port standard for the current scheme?
   */
  public static function isStandardPort(string $scheme, int $port): bool {
    return $port === (self::$schemes[$scheme] ?? null);
  }

  private function filterPort(?int $port): ?int {
    if ($port is null) {
      return null;
    }

    if (
      $this->scheme is nonnull && static::isStandardPort($this->scheme, $port)
    ) {
      return null;
    }

    if (1 > $port || 0xffff < $port) {
      throw new Exception\InvalidArgumentException(
        Str\format('Invalid port: %d. Must be between 1 and 65535', $port),
      );
    }

    return $port;
  }

  private function filterPath(string $path): string {
    return Regex\replace_with(
      $path,
      re"/(?:[^a-zA-Z0-9_\-\.~!\$&\'\(\)\*\+,;=%:@\/]++|%(?![A-Fa-f0-9]{2}))/",
      ($match) ==> \rawurlencode($match[0]),
    );
  }

  private function filterQueryAndFragment(?string $str): ?string {
    if ($str is null) {
      return $str;
    }

    return Regex\replace_with(
      $str,
      re"/(?:[^a-zA-Z0-9_\-\.~!\$&\'\(\)\*\+,;=%:@\/\?]++|%(?![A-Fa-f0-9]{2}))/",
      ($match) ==> \rawurlencode($match[0]),
    );
  }
}
