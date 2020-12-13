namespace Nuxed\Crypto\Symmetric\Encryption;

use namespace Nuxed\Crypto;
use namespace Nuxed\Crypto\Exception;
use namespace Nuxed\Crypto\Symmetric\Authentication;

/**
 * Decrypt a message
 */
function decrypt(
  string $ciphertext,
  Key $key,
  string $additionalData = '',
): Crypto\HiddenString {
  $pieces = unpack($ciphertext);
  $salt = $pieces[0] as string;
  $nonce = $pieces[1] as string;
  $encrypted = $pieces[2] as string;
  $auth = $pieces[3] as string;
  // Split our key into two keys: One for encryption, the other for
  // authentication. By using separate keys, we can reasonably dismiss
  // likely cross-protocol attacks.
  // This uses salted HKDF to split the keys, which is why we need the
  // salt in the first place. */
  list($encKey, $authKey) = Key\split($key, $salt);
  // Check the MAC first
  if (
    !Authentication\verify(
      $salt.$nonce.$additionalData.$encrypted,
      new Authentication\SignatureKey(new Crypto\HiddenString($authKey)),
      $auth,
    )
  ) {
    throw new Exception\InvalidMessageException(
      'Invalid message authentication code',
    );
  }
  \sodium_memzero(inout $salt);
  \sodium_memzero(inout $authKey);
  // crypto_stream_xor() can be used to encrypt and decrypt
  $plaintext = \sodium_crypto_stream_xor($encrypted, $nonce, $encKey);
  \sodium_memzero(inout $encrypted);
  \sodium_memzero(inout $nonce);
  \sodium_memzero(inout $encKey);
  return new Crypto\HiddenString($plaintext);
}
