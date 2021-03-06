/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Client;

use namespace HH\Lib\{C, Dict, Str, Vec};
use namespace Nuxed\Http\{Exception, Message};
use namespace Facebook\{TypeAssert, TypeSpec};

abstract class HttpClient implements IHttpClient {
  public function __construct(private HttpClientOptions $options = shape()) {}

  final public static function create(
    HttpClientOptions $options = shape(),
  ): HttpClient {
    return new CurlHttpClient($options);
  }

  /**
   * Create and send an HTTP request.
   *
   * Use an absolute path to override the base path of the client, or a
   * relative path to append to the base path of the client. The URL can
   * contain the query string as well.
   */
  final public async function request(
    string $method,
    string $uri,
    HttpClientOptions $options = shape(),
  ): Awaitable<Message\IResponse> {
    return await $this->send(
      Message\request(Message\HttpMethod::assert($method), Message\uri($uri)),
      $options,
    );
  }

  /**
   * Sends a request and returns a response.
   *
   * @throws Exception\IException If an error happens while processing the request.
   */
  final public async function send(
    Message\IRequest $request,
    HttpClientOptions $options = shape(),
  ): Awaitable<Message\IResponse> {
    $options = self::mergeOptions($this->options, $options);
    $request = $this->prepare($request, $options);

    return await $this->process($request, $options);
  }

  /**
   * Prepare the request before execution.
   */
  final private function prepare(
    Message\IRequest $request,
    HttpClientOptions $options,
  ): Message\IRequest {
    $uri = $request->getUri();
    $user = null;
    $password = null;
    $user_info = $uri->getUserInfo();
    if ($user_info is nonnull) {
      $user_info = Str\split($user_info, ':');
      $user = $user_info[0];
      $password = $user_info[1] ?? null;
    }
    if (!$request->hasHeader('Authorization')) {
      if ($user is nonnull) {
        $request = $request->withAddedHeader('Authorization', vec[
          Str\format(
            'Basic %s',
            \base64_encode($user.($password is null ? '' : ':'.$password)),
          ),
        ]);
      } else {
        $token = Shapes::idx($options, 'auth_bearer', null);
        if ($token is nonnull) {
          $request = $request->withAddedHeader('Authorization', vec[
            Str\format('Bearer %s', $token),
          ]);
        }
      }
    }
    $uri = $uri->withUserInfo('', null);

    $headers = Shapes::idx($options, 'headers', dict[]);
    foreach ($headers as $name => $value) {
      if (!$request->hasHeader($name)) {
        $request = $request->withHeader($name, $value);
      } else {
        $request = $request->withAddedHeader($name, $value);
      }
    }

    $protocol = $options['http_version'] ?? $request->getProtocolVersion();
    if ($protocol !== '1.1') {
      $request = $request->withProtocolVersion($protocol);
    }

    $body = $request->getBody();
    $body->seek(0);

    $baseUri = $options['base_uri'] ?? null;
    $base = null;
    if ($baseUri is nonnull) {
      $base = Message\uri($baseUri);
    }

    return $request->withUri(
      self::resolveUrl($uri, $base, Shapes::keyExists($options, 'unix_socket')),
    );
  }

  /**
   * Process the request and returns a response.
   *
   * @throws Exception\IException If an error happens while processing the request.
   */
  abstract protected function process(
    Message\IRequest $request,
    HttpClientOptions $options,
  ): Awaitable<Message\IResponse>;

  /**
   * Resolves a URL against a base URI.
   *
   * @see https://tools.ietf.org/html/rfc3986#section-5.2.2
   *
   * @throws InvalidArgumentException When an invalid URL is passed
   */
  private static function resolveUrl(
    Message\IUri $url,
    ?Message\IUri $base,
    bool $has_unix_socket,
  ): Message\IUri {
    if ($base is nonnull && '' === ($base->getScheme().$base->getAuthority())) {
      throw new Exception\InvalidArgumentException(Str\format(
        'Invalid "base_uri" option: host or scheme is missing in "%s".',
        $base->toString(),
      ));
    }

    if ($base is null && '' === $url->getScheme().$url->getAuthority()) {
      if ($has_unix_socket) {
        return $url;
      }

      throw new Exception\InvalidArgumentException(Str\format(
        'Invalid URL: no "base_uri" option was provided and host or scheme is missing in "%s".',
        $url->toString(),
      ));
    }

    if ($url->getScheme() is nonnull) {
      $url = $url->withPath(self::removeDotSegments($url->getPath()));
    } else {
      if ($url->getAuthority() is nonnull) {
        $url = $url->withPath(self::removeDotSegments($url->getPath()));
      } else {
        if ('' === $url->getPath()) {
          $url = $url->withPath($base?->getPath() ?? '')
            ->withQuery(
              $url->getQuery() !== ''
                ? $url->getQuery()
                : $base?->getQuery() ?? '',
            );
        } else {
          if (!Str\starts_with($url->getPath(), '/')) {
            if (C\contains(vec['', null], $base?->getPath())) {
              $url = $url->withPath('/'.$url->getPath());
            } else {
              $segments = Str\split($base?->getPath() ?? '', '/');
              $url = $url->withPath(
                Str\join(
                  Vec\take($segments, C\count($segments) - 1)
                    |> Vec\concat($$, vec[$url->getPath()]),
                  '/',
                ),
              );
            }
          }
          $url = $url->withPath(self::removeDotSegments($url->getPath()));
        }
        $url = $url->withHost($base?->getHost() ?? $url->getHost())
          ->withPort($base?->getPort() ?? $url->getPort());
        if ($base is nonnull) {
          $user_info = $base->getUserInfo();
          if ($user_info is nonnull) {
            $user_info = Str\split($user_info, ':');
            $url = $url->withUserInfo($user_info[0], $user_info[1] ?? null);
          }
        }
      }
      $url = $url->withScheme($base?->getScheme() ?? $url->getScheme());
    }
    if ('' === $url->getPath()) {
      $url = $url->withPath('/');
    }
    return $url;
  }

  /**
   * Removes dot-segments from a path.
   *
   * @see https://tools.ietf.org/html/rfc3986#section-5.2.4
   */
  <<__Memoize>>
  private static function removeDotSegments(string $path): string {
    $result = '';
    while (!C\contains(vec['', '.', '..'], $path)) {
      if (
        '.' === $path[0] &&
        (Str\starts_with($path, '../') || Str\starts_with($path, './'))
      ) {
        $path = Str\slice($path, Str\starts_with($path, './') ? 2 : 3);
      } else if ('/.' === $path || Str\starts_with($path, '/./')) {
        $path = Str\splice($path, '/', 0, 3);
      } else if ('/..' === $path || Str\starts_with($path, '/../')) {
        $i = Str\search_last($result, '/');
        $result = $i ? Str\slice($result, 0, $i) : '';
        $path = Str\splice($path, '/', 0, 4);
      } else {
        $i = Str\search($path, '/', 1) ?: Str\length($path);
        $result .= Str\slice($path, 0, $i);
        $path = Str\slice($path, $i);
      }
    }

    return $result;
  }

  <<__Memoize>>
  private static function mergeOptions(
    HttpClientOptions $current,
    HttpClientOptions $new,
  ): HttpClientOptions {
    $current = Shapes::toDict($current);
    $new = Shapes::toDict($new);
    $default = Shapes::toDict(static::DEFAULT_OPTIONS);
    $strSpec = TypeSpec\string();

    if (C\contains_key($new, 'resolve')) {
      $spec = TypeSpec\dict($strSpec, $strSpec);

      $new['resolve'] = Dict\merge(
        $spec->assertType($current['resolve'] ?? dict[]),
        $spec->assertType($new['resolve'] ?? dict[]),
      );
    }

    if (C\contains_key($new, 'ciphers')) {
      $spec = TypeSpec\vec($strSpec);

      $new['ciphers'] = Vec\concat(
        $spec->assertType($current['ciphers'] ?? vec[]),
        $spec->assertType($new['ciphers'] ?? vec[]),
      );
    }

    if (C\contains_key($new, 'headers')) {
      $spec = TypeSpec\dict($strSpec, TypeSpec\vec($strSpec));

      $new['headers'] = Dict\merge(
        $spec->assertType($current['headers'] ?? dict[]),
        $spec->assertType($new['headers'] ?? dict[]),
      );
    }

    if (C\contains_key($new, 'peer_fingerprint')) {
      $spec = TypeSpec\dict($strSpec, TypeSpec\vec($strSpec));

      $new['peer_fingerprint'] = Dict\merge(
        $spec->assertType($current['peer_fingerprint'] ?? dict[]),
        $spec->assertType($new['peer_fingerprint']),
      );
    }

    return TypeAssert\matches_type_structure(
      _Private\Structure::httpClientOptions(),
      Dict\merge($default, $current, $new),
    );
  }
}
