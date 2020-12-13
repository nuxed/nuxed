namespace Nuxed\Crypto\Asymmetric\Encryption;

use namespace Nuxed\Crypto;
use namespace Nuxed\Crypto\Symmetric;

/**
 * Decrypt a ciphertext using asymmetric cryptography
 * Wraps Symmetric\Encryption\decrypt()
 */
function decrypt(
  string $ciphertext,
  Key\PrivateKey $privateKey,
  Key\PublicKey $publicKey,
  string $additionalData = '',
): Crypto\HiddenString {
  return Symmetric\Encryption\decrypt(
    $ciphertext,
    new Symmetric\Encryption\Key(Key::shared($privateKey, $publicKey)),
    $additionalData,
  );
}
