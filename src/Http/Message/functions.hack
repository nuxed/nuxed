namespace Nuxed\Http\Message;

use namespace HH\Lib\IO;
use namespace Nuxed\Http\Message;

function cookie(
  string $value,
  ?int $expires = null,
  ?int $maxAge = null,
  ?string $path = null,
  ?string $domain = null,
  bool $secure = false,
  bool $httpOnly = false,
  ?Message\CookieSameSite $sameSite = null,
): Cookie {
  return new Cookie(
    $value,
    $expires,
    $maxAge,
    $path,
    $domain,
    $secure,
    $httpOnly,
    $sameSite,
  );
}

function request(
  HttpMethod $method,
  Message\IUri $uri,
  KeyedContainer<string, Container<string>> $headers = dict[],
  ?IO\SeekableReadWriteHandle $body = null,
  string $version = '1.1',
): Request {
  return new Request($method, $uri, $headers, $body, $version);
}

function response(
  int $status = 200,
  KeyedContainer<string, Container<string>> $headers = dict[],
  ?IO\SeekableReadWriteHandle $body = null,
  string $version = '1.1',
  ?string $reason = null,
): Response {
  return new Response($status, $headers, $body, $version, $reason);
}

function uri(string $uri): Uri {
  return new Uri($uri);
}
