namespace Nuxed\Crypto\Str;

/**
 * Compares two strings using the same time whether they're equal or not.
 */
function equals(string $known, string $user): bool {
  return \hash_equals($known, $user);
}
