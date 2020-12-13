namespace Nuxed\Message\Cookie;

use namespace Nuxed\Http;
use namespace Nuxed\Http\Message;

/**
 * Create a new cookie with a long expiration date into the future.
 */
function forever(string $value): Message\ICookie {
  return remember(Http\Message\cookie($value));
}

/**
 * Set the expiration date for the given cookie to the future.
 */
function remember(Message\ICookie $cookie): Message\ICookie {
  $future = new \DateTimeImmutable('+5 years', new \DateTimeZone('UTC'));

  return $cookie->withExpires($future->getTimestamp());
}

/**
 * Marks the cookie stale by setting the expiration date
 * to 5 years ago.
 */
function forget(Message\ICookie $cookie): Message\ICookie {
  $future = new \DateTimeImmutable('-5 years', new \DateTimeZone('UTC'));

  return $cookie->withExpires($future->getTimestamp());
}
