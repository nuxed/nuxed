namespace Nuxed\Crypto\Asymmetric\Authentication\Key;

use namespace Nuxed\Crypto;
use namespace Nuxed\Crypto\Asymmetric\{Authentication, Encryption};

final class SignaturePublicKey extends Authentication\SignatureKey {
  const int LENGTH = \SODIUM_CRYPTO_SIGN_PUBLICKEYBYTES;
  public function __construct(Crypto\HiddenString $material) {
    if (Crypto\Binary\length($material->toString()) !== static::LENGTH) {
      throw new Crypto\Exception\InvalidKeyException(
        'Signature public key must be const(SignaturePublicKey::LENGTH) bytes long',
      );
    }

    parent::__construct($material);
  }

  /**
   * Get an encryption public key from a signing public key.
   */
  public function toEncryptionKey(): Encryption\Key\PublicKey {
    $ed25519_pk = $this->toString();
    $x25519_pk = \sodium_crypto_sign_ed25519_pk_to_curve25519($ed25519_pk);

    return new Encryption\Key\PublicKey(new Crypto\HiddenString($x25519_pk));
  }
}
