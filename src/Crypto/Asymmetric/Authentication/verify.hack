namespace Nuxed\Crypto\Asymmetric\Authentication;

use namespace Nuxed\Crypto\{Binary, Exception};

/**
 * Verify a signed message with the correct public key
 */
function verify(
  string $message,
  Key\SignaturePublicKey $key,
  string $signature,
): bool {
  if (Binary\length($signature) !== \SODIUM_CRYPTO_SIGN_BYTES) {
    throw new Exception\InvalidSignatureException(
      'Signature is not the correct length; is it encoded?',
    );
  }

  return (bool)\sodium_crypto_sign_verify_detached(
    $signature,
    $message,
    $key->toString(),
  );
}
