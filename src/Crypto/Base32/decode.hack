namespace Nuxed\Crypto\Base32;

use namespace Nuxed\Crypto\_Private;

/**
 * Decode a Base32-encoded string into raw binary.
 *
 * Base32 character set:
 *  [a-z]      [2-7]
 *  0x61-0x7a, 0x32-0x37
 */
function decode(string $src, bool $strictPadding = false): string {
  return _Private\Base32::decode($src, false, $strictPadding);
}

/**
 * Decode a Base32-encoded uppercase string into raw binary.
 *
 * Base32 character set:
 *  [A-Z]      [2-7]
 *  0x41-0x5a, 0x32-0x37
 */
function decode_upper(string $src, bool $strictPadding = false): string {
  return _Private\Base32::decode($src, true, $strictPadding);
}
