namespace Nuxed\Crypto\Asymmetric\Authentication\Key;

use namespace Nuxed\Crypto;
use namespace Nuxed\Crypto\Asymmetric\{Authentication, Encryption};

final class SignaturePrivateKey extends Authentication\SignatureKey {
  const int LENGTH = \SODIUM_CRYPTO_SIGN_SECRETKEYBYTES;
  public function __construct(Crypto\HiddenString $material) {
    if (Crypto\Binary\length($material->toString()) !== static::LENGTH) {
      throw new Crypto\Exception\InvalidKeyException(
        'Signature private key must be const(SignaturePrivateKey::LENGTH) bytes long',
      );
    }

    parent::__construct($material);
  }

  /**
   * Get an encryption private key from a signing private key.
   */
  public function toEncryptionKey(): Encryption\Key\PrivateKey {
    $ed25519_sk = $this->toString();
    $x25519_sk = \sodium_crypto_sign_ed25519_sk_to_curve25519($ed25519_sk);
    return new Encryption\Key\PrivateKey(new Crypto\HiddenString($x25519_sk));
  }

  /**
   * See the appropriate derived class.
   */
  public function derivePublicKey(): SignaturePublicKey {
    $publicKey = \sodium_crypto_sign_publickey_from_secretkey(
      $this->toString(),
    );
    return new SignaturePublicKey(new Crypto\HiddenString($publicKey));
  }
}
