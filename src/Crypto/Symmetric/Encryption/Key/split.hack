namespace Nuxed\Crypto\Symmetric\Encryption\Key;

use namespace Nuxed\Crypto\Hkdf;
use namespace Nuxed\Crypto\Symmetric\Encryption;

/**
 * Split a key (using HKDF-BLAKE2b instead of HKDF-HMAC-*)
 */
function split(Encryption\Key $master, string $salt): (string, string) {
  $binary = $master->toString();
  return tuple(
    Hkdf\blake2b(
      $binary,
      \SODIUM_CRYPTO_SECRETBOX_KEYBYTES,
      'NuxedCrypto|EncryptionKey',
      $salt,
    ),
    Hkdf\blake2b(
      $binary,
      \SODIUM_CRYPTO_AUTH_KEYBYTES,
      'AuthenticationKeyFor_|NuxedCrypto',
      $salt,
    ),
  );
}
