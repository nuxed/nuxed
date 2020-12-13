namespace Nuxed\Crypto\Binary;

/**
 * Returns a substring of length `$length` of the given binary string starting at the
 * `$offset`.
 */
function slice(string $str, int $offset = 0, ?int $length = null): string {
  if ($length === 0) {
    return '';
  }

  return \mb_substr($str, $offset, $length, '8bit');
}
