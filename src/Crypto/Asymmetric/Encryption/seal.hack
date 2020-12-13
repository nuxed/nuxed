namespace Nuxed\Crypto\Asymmetric\Encryption;

use namespace Nuxed\Crypto;

/**
 * Encrypt a message with a target users' public key
 */
function seal(Crypto\HiddenString $plaintext, Key\PublicKey $key): string {
  return \sodium_crypto_box_seal($plaintext->toString(), $key->toString());
}
