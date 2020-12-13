namespace Nuxed\Http\Message\Request;

use namespace HH\Lib\{C, Str};
use namespace Nuxed\{Http, Json};
use namespace Nuxed\Http\Message;

/**
 * Returns true if the request is a XMLHttpRequest.
 *
 * It works if your JavaScript library sets an X-Requested-With HTTP header.
 * It is known to work with common JavaScript frameworks:
 *
 * @see https://wikipedia.org/wiki/List_of_Ajax_frameworks#JavaScript
 *
 * @return bool true if the request is an XMLHttpRequest, false otherwise
 */
function is_xml_http_request(Http\Message\IRequest $request): bool {
  return 'xmlhttprequest' ===
    Str\lowercase($request->getHeaderLine('X-Requested-With'));
}

function is_no_cache(Http\Message\IRequest $request): bool {
  return Message\_Private\has_cache_control_directive($request, 'no-cache') ||
    'no-cache' === $request->getHeaderLine('Pragma');
}

/**
 * Checks whether or not the method is safe.
 *
 * @see https://tools.ietf.org/html/rfc7231#section-4.2.1
 */
function is_method_safe(Http\Message\IRequest $request): bool {
  return C\contains(
    vec['GET', 'HEAD', 'OPTIONS', 'TRACE'],
    $request->getMethod(),
  );
}

/**
 * Checks whether or not the method is idempotent.
 */
function is_method_idempotent(Http\Message\IRequest $request): bool {
  return C\contains(
    vec['HEAD', 'GET', 'PUT', 'DELETE', 'TRACE', 'OPTIONS', 'PURGE'],
    $request->getMethod(),
  );
}

/**
 * Checks whether the method is cacheable or not.
 *
 * @see https://tools.ietf.org/html/rfc7231#section-4.2.3
 */
function is_method_cacheable(Http\Message\IRequest $request): bool {
  return C\contains(vec['GET', 'HEAD'], $request->getMethod());
}

function json(
  Message\Uri $uri,
  mixed $data,
  string $method = 'POST',
  KeyedContainer<string, Container<string>> $headers = dict[],
  string $version = '1.1',
): Message\Request {
  $flags = \JSON_HEX_TAG | \JSON_HEX_APOS | \JSON_HEX_AMP | \JSON_HEX_QUOT;
  $body = Message\Body\temporary();
  $body->write(Json\encode($data, false, $flags));
  $headers = dict($headers);
  $headers['content-type'] ??= vec['application/json'];

  return Message\request($method, $uri, $headers, $body, $version);
}
