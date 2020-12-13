namespace Nuxed\Crypto\Symmetric\Encryption;

use namespace Nuxed\Crypto;
use namespace HH\Lib\SecureRandom;
use namespace Nuxed\Crypto\Symmetric\Authentication;

/**
 * Encrypt a message
 *
 * (Encrypt then MAC -- xsalsa20 then keyed-Blake2b)
 * You don't need to worry about chosen-ciphertext attacks.
 */
function encrypt(
  Crypto\HiddenString $plaintext,
  Key $key,
  string $additionalData = '',
): string {
  // Generate a nonce and HKDF salt:
  $nonce = SecureRandom\string(\SODIUM_CRYPTO_SECRETBOX_NONCEBYTES);
  $salt = SecureRandom\string(32);
  // Split our key into two keys: One for encryption, the other for
  // authentication. By using separate keys, we can reasonably dismiss
  // likely cross-protocol attacks.
  // This uses salted HKDF to split the keys, which is why we need the
  // salt in the first place.
  list($encKey, $authKey) = Key\split($key, $salt);
  // Encrypt our message with the encryption key:
  $encrypted = \sodium_crypto_stream_xor(
    $plaintext->toString(),
    $nonce,
    $encKey,
  );
  \sodium_memzero(inout $encKey);
  // Calculate an authentication tag:
  $auth = Authentication\authenticate(
    $salt.$nonce.$additionalData.$encrypted,
    new Authentication\SignatureKey(new Crypto\HiddenString($authKey)),
  );
  // wipe authentication key from memory
  \sodium_memzero(inout $authKey);
  $message = $salt.$nonce.$encrypted.$auth;
  // Wipe every superfluous piece of data from memory
  \sodium_memzero(inout $nonce);
  \sodium_memzero(inout $salt);
  \sodium_memzero(inout $encrypted);
  \sodium_memzero(inout $auth);
  return $message;
}
