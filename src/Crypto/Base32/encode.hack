namespace Nuxed\Crypto\Base32;
use namespace Nuxed\Crypto\_Private;

/**
 * Convert a binary string into a base32-encoded string without cache-timing
 * leaks (as per RFC 4648)
 *
 * Base32 character set:
 *  [a-z]      [2-7]
 *  0x61-0x7a, 0x32-0x37
 */
function encode(string $src, bool $strictPadding = false): string {
  return _Private\Base32::encode($src, false, $strictPadding);
}

/**
 * Convert a binary string into a base32-encoded string without cache-timing
 * leaks, returning uppercase letters (as per RFC 4648).
 *
 * Base32 character set:
 *  [A-Z]      [2-7]
 *  0x41-0x5a, 0x32-0x37
 */
function encode_upper(string $src, bool $strictPadding = false): string {
  return _Private\Base32::encode($src, true, $strictPadding);
}
