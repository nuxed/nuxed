namespace Nuxed\Crypto\Symmetric\Password;

use namespace Nuxed\Crypto;
use namespace Nuxed\Crypto\Password;
use namespace Nuxed\Crypto\Symmetric\Encryption;

/**
 * Is this password hash stale ?
 */
function stale(
  string $stored,
  Encryption\Key $key,
  Crypto\SecurityLevel $level = Crypto\SecurityLevel::INTERACTIVE,
): bool {
  $stored = Encryption\decrypt($stored, $key);
  return Password\stale($stored->toString(), $level);
}
