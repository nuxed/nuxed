namespace Nuxed\Crypto\Binary;

/**
 * Returns the length of the given binary string.
 */
function length(string $str): int {
  return \mb_strlen($str, '8bit');
}
