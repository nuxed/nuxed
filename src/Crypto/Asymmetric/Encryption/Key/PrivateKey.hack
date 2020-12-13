namespace Nuxed\Crypto\Asymmetric\Encryption\Key;

use namespace Nuxed\Crypto;
use namespace Nuxed\Crypto\Binary;
use namespace Nuxed\Crypto\Asymmetric\Encryption;

final class PrivateKey extends Encryption\Key {
  const int LENGTH = \SODIUM_CRYPTO_BOX_SECRETKEYBYTES;
  public function __construct(Crypto\HiddenString $material) {
    if (Binary\length($material->toString()) !== static::LENGTH) {
      throw new Crypto\Exception\InvalidKeyException(
        'Encryption private key must be const(PrivateKey::LENGTH) bytes long',
      );
    }

    parent::__construct($material);
  }

  /**
   * See the appropriate derived class.
   */
  public function derivePublicKey(): PublicKey {
    $publicKey = \sodium_crypto_box_publickey_from_secretkey($this->toString());
    return new PublicKey(new Crypto\HiddenString($publicKey));
  }
}
