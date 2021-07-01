/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http\Message\Response;

use namespace HH\Lib\{C, Math, Str};
use namespace Nuxed\Http\Message;
use namespace Nuxed\Http;
use namespace Nuxed\Http\Message\_Private;

/**
 * Modifies the response so that it conforms to the rules defined for a 304 status code.
 *
 * This sets the status, removes the body, and discards any headers
 * that MUST NOT be included in 304 responses.
 *
 * @see http://tools.ietf.org/html/rfc2616#section-10.3.5
 */
function without_modifications(
  Http\Message\IResponse $response,
): Http\Message\IResponse {
  $new = $response
    ->withStatus(304)
    ->withBody(Message\Body\memory());

  // remove headers that MUST NOT be included with 304 Not Modified responses
  foreach (
    vec[
      'Allow',
      'Content-Encoding',
      'Content-Language',
      'Content-Length',
      'Content-MD5',
      'Content-Type',
      'Last-Modified',
    ] as $header
  ) {
    $new = $new->withoutHeader($header);
  }

  return $new;
}

/**
 * Check whether the given response contains the given cache control directive.
 */
function has_cache_control_directive(
  Http\Message\IResponse $response,
  string $directive,
): bool {
  return _Private\has_cache_control_directive($response, $directive);
}

/**
 * Retrieve the value of the given cache control directive.
 *
 * Note: if this function returns null, it doesn't mean that the directive doesn't exist,
 *    as some cache control directives don't have an actual value.
 *
 * @see has_cache_control_directive()
 */
function get_cache_control_directive(
  Http\Message\IResponse $response,
  string $directive,
): ?int {
  return _Private\get_cache_control_directive($response, $directive);
}

/**
 * Return the given response with the given cache control directive.
 */
function with_cache_control_directive(
  Http\Message\IResponse $response,
  string $directive,
  ?int $seconds = null,
): Http\Message\IResponse {
  return _Private\with_cache_control_directive($response, $directive, $seconds);
}

/**
 * Returns the given response without the given cache control directive.
 */
function without_cache_control_directive(
  Http\Message\IResponse $response,
  string $directive,
): Http\Message\IResponse {
  return _Private\without_cache_control_directive($response, $directive);
}

/**
 * Returns true if the response must be revalidated by caches.
 *
 * This function indicates that the response must not be served stale by a
 * cache in any circumstance without first revalidating with the origin.
 * When present, the TTL of the response should not be overridden to be
 * greater than the value provided by the origin.
 */
function must_revalidate(Http\Message\IResponse $response): bool {
  return has_cache_control_directive($response, 'must-revalidate') ||
    has_cache_control_directive($response, 'proxy-revalidate');
}

/**
 * Returns true if the response may safely be kept in a shared (surrogate) cache.
 *
 * Responses marked "private" with an explicit Cache-Control directive are
 * considered uncacheable.
 *
 * Responses with neither a freshness lifetime (Expires, max-age) nor cache
 * validator (Last-Modified, ETag) are considered uncacheable because there is
 * no way to tell when or how to remove them from the cache.
 *
 * Note that RFC 7231 and RFC 7234 possibly allow for a more permissive implementation,
 * for example "status codes that are defined as cacheable by default [...]
 * can be reused by a cache with heuristic expiration unless otherwise indicated"
 * (https://tools.ietf.org/html/rfc7231#section-6.1)
 */
function is_cacheable(Http\Message\IResponse $response): bool {
  if (
    !C\contains(
      vec[200, 203, 300, 301, 302, 404, 410],
      $response->getStatusCode(),
    )
  ) {
    return false;
  }

  $cacheControl = $response->getHeader('cache-control');

  if (C\contains($cacheControl, 'no-store')) {
    return false;
  }

  foreach ($cacheControl as $value) {
    if (Str\starts_with($value, 'private')) {
      return false;
    }
  }

  return is_validateable($response) || is_fresh($response);
}

/**
 * Returns true if the response includes headers that can be used to validate
 * the response with the origin server using a conditional GET request.
 */
function is_validateable(Http\Message\IResponse $response): bool {
  return $response->hasHeader('Last-Modified') || $response->hasHeader('ETag');
}

/**
 * Returns true if the response is "fresh".
 *
 * Fresh responses may be served from cache without any interaction with the
 * origin. A response is considered fresh when it includes a Cache-Control/max-age
 * indicator or Expires header and the calculated age is less than the freshness lifetime.
 */
function is_fresh(Http\Message\IResponse $response): bool {
  $ttl = get_ttl($response);
  return $ttl is null ? false : $ttl > 0;
}

/**
 * Returns true if the response is marked as "immutable".
 */
function is_immutable(Http\Message\IResponse $response): bool {
  return _Private\has_cache_control_directive($response, 'immutable');
}

/**
 * Return the response with the "immutable" cache directive.
 */
function with_immutable(
  Http\Message\IResponse $response,
): Http\Message\IResponse {
  return with_cache_control_directive($response, 'immutable');
}

/**
 * Return the response without the "immutable" cache directive.
 */
function without_immutable(
  Http\Message\IResponse $response,
): Http\Message\IResponse {
  return without_cache_control_directive($response, 'immutable');
}

/**
 * Returns the response's time-to-live in seconds.
 *
 * It returns null when no freshness information is present in the response.
 *
 * When the responses TTL is <= 0, the response may not be served from cache without first
 * revalidating with the origin.
 */
function get_ttl(Http\Message\IResponse $response): ?int {
  $maxAge = get_max_age($response);

  return null !== $maxAge ? $maxAge - get_age($response) : null;
}

/**
 * Sets the Date header.
 */
function with_date(
  Http\Message\IResponse $response,
  int $timestamp,
): Http\Message\IResponse {
  return _Private\with_date_header($response, 'Date', $timestamp);
}

/**
 * Returns the age of the response in seconds.
 */
function get_age(Http\Message\IResponse $response): int {
  if ($response->hasHeader('Age')) {
    return (int)$response->getHeaderLine('Age');
  }

  if (!$response->hasHeader('Date')) {
    return 0;
  }

  return Math\maxva(\time() - (get_date($response) as nonnull), 0);
}

/**
 * Marks the response stale by setting the Age header to be equal to the maximum age of the response.
 */
function stale(Http\Message\IResponse $response): Http\Message\IResponse {
  if (is_fresh($response)) {
    return $response->withoutHeader('Expires')
      ->withHeader('Age', vec[
        (string)get_max_age($response),
      ]);
  }

  return $response;
}

/**
 * Sets the Expires HTTP header with a timestamp.
 */
function with_expires(
  Http\Message\IResponse $response,
  int $timestamp,
): Http\Message\IResponse {
  return _Private\with_date_header($response, 'Expires', $timestamp);
}

/**
 * Removes the Expires HTTP header.
 */
function without_expires(
  Http\Message\IResponse $response,
): Http\Message\IResponse {
  return _Private\with_date_header($response, 'Expires', null);
}

/**
 * Sets the number of seconds after which the response should no longer be considered fresh.
 *
 * This function sets the Cache-Control max-age directive.
 */
function with_max_age(
  Http\Message\IResponse $response,
  int $value,
): Http\Message\IResponse {
  return with_cache_control_directive($response, 'max-age', $value);
}

/**
 * Sets the number of seconds after which the response should no longer be considered fresh by shared caches.
 *
 * This function sets the Cache-Control s-maxage directive.
 */
function with_shared_max_age(
  Http\Message\IResponse $response,
  int $value,
): Http\Message\IResponse {
  return with_cache_control_directive($response, 'public')
    |> with_cache_control_directive($$, 's-maxage', $value);
}

/**
 * Sets the response's time-to-live for shared caches in seconds.
 *
 * This function adjusts the Cache-Control/s-maxage directive.
 */
function with_ttl(
  Http\Message\IResponse $response,
  int $seconds,
): Http\Message\IResponse {
  return with_shared_max_age($response, get_age($response) + $seconds);
}

/**
 * Sets the response's time-to-live for private/client caches in seconds.
 *
 * This function adjusts the Cache-Control/max-age directive.
 */
function with_client_ttl(
  Http\Message\IResponse $response,
  int $seconds,
): Http\Message\IResponse {
  return with_max_age($response, get_age($response) + $seconds);
}

/**
 * Returns the Last-Modified HTTP header as a timestamp.
 */
function get_last_modified(Http\Message\IResponse $response): ?int {
  return _Private\get_date_header($response, 'Last-Modified');
}

/**
 * Sets the Last-Modified HTTP header with a timestamp.
 */
function with_last_modified(
  Http\Message\IResponse $response,
  int $timestamp,
): Http\Message\IResponse {
  return _Private\with_date_header($response, 'Last-Modified', $timestamp);
}

/**
 * Remove the Last-Modified HTTP header.
 */
function without_last_modified(
  Http\Message\IResponse $response,
): Http\Message\IResponse {
  return _Private\with_date_header($response, 'Last-Modified', null);
}

/**
 * Returns the number of seconds after the time specified in the response's Date
 * header when the response should no longer be considered fresh.
 *
 * First, it checks for a s-maxage directive, then a max-age directive, and then it falls
 * back on an expires header. It returns null when no maximum age can be established.
 */
function get_max_age(Http\Message\IResponse $response): ?int {
  if (!$response->hasHeader('cache-control')) {
    return null;
  }

  if (has_cache_control_directive($response, 's-maxage')) {
    return get_cache_control_directive($response, 's-maxage');
  }

  if (has_cache_control_directive($response, 'max-age')) {
    return get_cache_control_directive($response, 'max-age');
  }

  $expires = get_expires($response);
  if ($expires is nonnull) {
    $timestamp = get_date($response);

    return $expires - ($timestamp as nonnull);
  }

  return null;
}

/**
 * Returns the value of the response's Expires header as a timestamp.
 */
function get_expires(Http\Message\IResponse $response): ?int {
  if (!$response->hasHeader('Expires')) {
    return null;
  }

  try {
    return _Private\get_date_header($response, 'Expires');
  } catch (\RuntimeException $e) {
    // according to RFC 2616 invalid date formats (e.g. "0" and "-1") must be treated as in the past
    return (\time() - 172800);
  }
}

/**
 * Returns the response's Date header as a timestamp.
 */
function get_date(Http\Message\IResponse $response): ?int {
  return _Private\get_date_header($response, 'Date');
}

/**
 * Returns the literal value of the ETag HTTP header.
 */
function get_etag(Http\Message\IResponse $response): ?string {
  if (!$response->hasHeader('ETag')) {
    return null;
  }

  return $response->getHeaderLine('ETag');
}

/**
 * Sets the ETag value.
 *
 * @param string  $etag The ETag unique identifier
 * @param bool    $weak Whether you want a weak ETag or not
 */
function with_etag(
  Http\Message\IResponse $response,
  string $etag,
  bool $weak = false,
): Http\Message\IResponse {
  if (!Str\contains($etag, '"')) {
    $etag = '"'.$etag.'"';
  }

  return $response->withHeader('ETag', vec[($weak ? 'W/' : '').$etag]);
}

/**
 * Removes the ETag header.
 */
function without_etag(
  Http\Message\IResponse $response,
): Http\Message\IResponse {
  return $response->withoutHeader('ETag');
}

/**
 * Is response invalid?
 *
 * @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
 */
function is_invalid(Http\Message\IResponse $response): bool {
  return $response->getStatusCode() < Http\Message\StatusCode::CONTINUE ||
    $response->getStatusCode() >= 600;
}

/**
 * Is response informative?
 */
function is_informational(Http\Message\IResponse $response): bool {
  return $response->getStatusCode() >= Http\Message\StatusCode::CONTINUE &&
    $response->getStatusCode() < Http\Message\StatusCode::OK;
}

/**
 * Is response successful?
 */
function is_successful(Http\Message\IResponse $response): bool {
  return $response->getStatusCode() >= Http\Message\StatusCode::OK &&
    $response->getStatusCode() < Http\Message\StatusCode::MULTIPLE_CHOICES;
}

/**
 * Is the response a redirect?
 */
function is_redirection(Http\Message\IResponse $response): bool {
  return $response->getStatusCode() >=
    Http\Message\StatusCode::MULTIPLE_CHOICES &&
    $response->getStatusCode() < Http\Message\StatusCode::BAD_REQUEST;
}

/**
 * Is there a client error?
 */
function is_client_error(Http\Message\IResponse $response): bool {
  return $response->getStatusCode() >= Http\Message\StatusCode::BAD_REQUEST &&
    $response->getStatusCode() < Http\Message\StatusCode::INTERNAL_SERVER_ERROR;
}

/**
 * Was there a server side error?
 */
function is_server_error(Http\Message\IResponse $response): bool {
  return $response->getStatusCode() >=
    Http\Message\StatusCode::INTERNAL_SERVER_ERROR &&
    $response->getStatusCode() < 600;
}

/**
 * Is the response OK?
 */
function is_ok(Http\Message\IResponse $response): bool {
  return Http\Message\StatusCode::OK === $response->getStatusCode();
}

/**
 * Is the response forbidden?
 */
function is_forbidden(Http\Message\IResponse $response): bool {
  return Http\Message\StatusCode::FORBIDDEN === $response->getStatusCode();
}

/**
 * Is the response a not found error?
 */
function is_not_found(Http\Message\IResponse $response): bool {
  return Http\Message\StatusCode::NOT_FOUND === $response->getStatusCode();
}

/**
 * Is the response a redirect of some form?
 */
function is_redirect(
  Http\Message\IResponse $response,
  ?string $location = null,
): bool {
  return C\contains(
    vec[
      Http\Message\StatusCode::CREATED,
      Http\Message\StatusCode::MOVED_PERMANENTLY,
      Http\Message\StatusCode::FOUND,
      Http\Message\StatusCode::SEE_OTHER,
      Http\Message\StatusCode::TEMPORARY_REDIRECT,
      Http\Message\StatusCode::PERMANENT_REDIRECT,
    ],
    $response->getStatusCode(),
  ) &&
    (null === $location || $location === $response->getHeaderLine('Location'));
}

/**
 * Is the response empty?
 */
function is_empty(Http\Message\IResponse $response): bool {
  return C\contains(
    vec[
      Http\Message\StatusCode::NO_CONTENT,
      Http\Message\StatusCode::NOT_MODIFIED,
    ],
    $response->getStatusCode(),
  );
}

/**
 * Create a plain text response.
 *
 * Produces a text response with a Content-Type of text/plain and a default
 * status of 200.
 */
function text(
  string $text,
  int $status = Http\Message\StatusCode::OK,
  KeyedContainer<string, Container<string>> $headers = dict[],
): Message\Response {
  $body = Message\Body\memory($text);

  return new Message\Response($status, _Private\inject_content_type_in_headers(
    'text/plain; charset=utf-8',
    $headers,
  ))
    |> $$->withBody($body);
}

/**
 * Create an HTML response.
 *
 * Produces an HTML response with a Content-Type of text/html and a default
 * status of 200.
 */
function html(
  string $html,
  int $status = Http\Message\StatusCode::OK,
  KeyedContainer<string, Container<string>> $headers = dict[],
): Message\Response {
  $body = Message\Body\memory($html);

  return new Message\Response($status, _Private\inject_content_type_in_headers(
    'text/html; charset=utf8',
    $headers,
  ))
    |> $$->withBody($body);
}

/**
 * Create an XML response.
 *
 * Produces an XML response with a Content-Type of application/xml and a default
 * status of 200.
 */
function xml(
  string $xml,
  int $status = Http\Message\StatusCode::OK,
  KeyedContainer<string, Container<string>> $headers = dict[],
): Message\Response {
  $body = Message\Body\memory($xml);

  return new Message\Response($status, _Private\inject_content_type_in_headers(
    'application/xml; charset=utf8',
    $headers,
  ))
    |> $$->withBody($body);
}

/**
 * Create a plain text response from a text file.
 *
 * Produces a text response with a Content-Type of text/plain and a default
 * status of 200.
 */
function text_file(
  string $file,
  int $status = Http\Message\StatusCode::OK,
  KeyedContainer<string, Container<string>> $headers = dict[],
): Message\Response {
  $body = Message\Body\file($file);

  return new Message\Response($status, _Private\inject_content_type_in_headers(
    'text/plain; charset=utf-8',
    $headers,
  ))
    |> $$->withBody($body);
}

/**
 * Create an HTML response from an HTML file.
 *
 * Produces an HTML response with a Content-Type of text/html and a default
 * status of 200.
 */
function html_file(
  string $file,
  int $status = Http\Message\StatusCode::OK,
  KeyedContainer<string, Container<string>> $headers = dict[],
): Message\Response {
  $body = Message\Body\file($file);

  return new Message\Response($status, _Private\inject_content_type_in_headers(
    'text/html; charset=utf8',
    $headers,
  ))
    |> $$->withBody($body);
}

/**
 * Create an XML response from an XML file.
 *
 * Produces an XML response with a Content-Type of application/xml and a default
 * status of 200.
 */
function xml_file(
  string $file,
  int $status = Http\Message\StatusCode::OK,
  KeyedContainer<string, Container<string>> $headers = dict[],
): Message\Response {
  $body = Message\Body\file($file);

  return new Message\Response($status, _Private\inject_content_type_in_headers(
    'application/xml; charset=utf8',
    $headers,
  ))
    |> $$->withBody($body);
}

/**
 * Create a redirect response.
 *
 * Produces a redirect response with a Location header and the given status
 * (302 by default).
 *
 * Note: redirect function overwrites the `location` $headers value.
 */
function redirect(
  Http\Message\IUri $uri,
  int $status = Http\Message\StatusCode::FOUND,
  KeyedContainer<string, Container<string>> $headers = dict[],
): Message\Response {
  $headers = dict($headers);
  $headers['location'] = vec[
    $uri->toString(),
  ];

  return new Message\Response($status, $headers);
}

/**
 * Create an empty response with the given status code.
 *
 * @param int $status Status code for the response, if any.
 * @param KeyedContainer<string, Container<string>> $headers Container of headers to use at initialization.
 */
function empty(
  int $status = Http\Message\StatusCode::NO_CONTENT,
  KeyedContainer<string, Container<string>> $headers = dict[],
): Message\Response {
  return new Message\Response($status, $headers);
}

/**
 * Create a JSON response with the given data.
 *
 * Default JSON encoding is performed with the following options, which
 * produces RFC4627-compliant JSON, capable of embedding into HTML.
 *
 * - JSON_HEX_TAG
 * - JSON_HEX_APOS
 * - JSON_HEX_AMP
 * - JSON_HEX_QUOT
 * - JSON_UNESCAPED_SLASHES
 *
 * @param KeyedContainer<string, mixed>             $data Data to convert to JSON object.
 * @param int                                       $status Integer status code for the response; 200 by default.
 * @param KeyedContainer<string, Container<string>> $headers Container of headers to use at initialization.
 * @param int                                       $encodingOptions JSON encoding options to use.
 */
function json(
  KeyedContainer<string, mixed> $data,
  int $status = Http\Message\StatusCode::OK,
  KeyedContainer<string, Container<string>> $headers = dict[],
  ?int $encodingOptions = null,
): JsonResponse {
  return new JsonResponse($data, $status, $headers, $encodingOptions);
}
