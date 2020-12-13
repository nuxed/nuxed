namespace Nuxed\Crypto\Asymmetric\Encryption;

use namespace Nuxed\Crypto;
use namespace Nuxed\Crypto\Symmetric;

/**
 * Encrypt a string using asymmetric cryptography
 * Wraps Symmetric\Encryption\encrypt()
 */
function encrypt(
  Crypto\HiddenString $plaintext,
  Key\PrivateKey $privateKey,
  Key\PublicKey $publicKey,
  string $additionalData = '',
): string {
  return Symmetric\Encryption\encrypt(
    $plaintext,
    new Symmetric\Encryption\Key(Key::shared($privateKey, $publicKey)),
    $additionalData,
  );
}
