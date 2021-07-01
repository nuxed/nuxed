/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Emitter\_Private;

use namespace HH\Lib\Str;
use namespace Nuxed\Http\Message;

/**
  * @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie
  */
function cookie_header(string $name, Message\ICookie $cookie): string {
  $cookieStringParts = vec[
    \urlencode($name).'='.\urlencode($cookie->getValue()),
  ];

  /**
   * __Host- prefix : Cookies with names starting with __Host- must not
   * have a domain specified (and therefore aren't sent to subdomains)
   * and the path must be /.
   */
  $hostOnly = Str\starts_with($name, '__Host-');
  $domain = $cookie->getDomain();
  if ($domain is nonnull && !$hostOnly) {
    $cookieStringParts[] = Str\format('Domain=%s', $domain);
  }

  $path = $cookie->getPath();
  if ($path is nonnull && !$hostOnly) {
    $cookieStringParts[] = Str\format('Path=%s', $path);
  } else if ($hostOnly) {
    $cookieStringParts[] = 'Path=/';
  }

  /*
   * If both Expires and Max-Age are set, Max-Age has precedence.
   */
  $expires = $cookie->getExpires();
  $maxAge = $cookie->getMaxAge();
  if ($maxAge is nonnull) {
    $cookieStringParts[] = Str\format(
      'MaxAge=%s',
      \date('D, d M Y H:i:s T', $maxAge),
    );
  } else if ($expires is nonnull) {
    $cookieStringParts[] = Str\format(
      'Expires=%s',
      \date('D, d M Y H:i:s T', $expires),
    );
  }

  /*
   * __Host- prefix : Cookies with names starting with __Host- must be set
   * with the secure flag, must be from a secure page (HTTPS)
   *
   * __Secure- prefix : Cookies names starting with __Secure- must be set
   * with the secure flag from a secure page (HTTPS).
   */
  if (
    $cookie->getSecure() || Str\starts_with($name, '__Secure-') || $hostOnly
  ) {
    $cookieStringParts[] = 'Secure';
  }

  if ($cookie->getHttpOnly()) {
    $cookieStringParts[] = 'HttpOnly';
  }

  $sameSite = $cookie->getSameSite();
  if ($sameSite is nonnull) {
    $cookieStringParts[] = Str\format('SameSite=%s', $sameSite as string);
  }

  return Str\join($cookieStringParts, '; ');
}
