namespace Nuxed\Crypto\Symmetric\Password;

use namespace Nuxed\Crypto\Symmetric\Encryption;

/**
 * Rotate the password encryption key
 */
function rotate(
  string $stored,
  Encryption\Key $oldKey,
  Encryption\Key $newKey,
): string {
  return Encryption\encrypt(Encryption\decrypt($stored, $oldKey), $newKey);
}
