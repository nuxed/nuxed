namespace Nuxed\Crypto\Asymmetric\Encryption\Key;

use namespace Nuxed\Crypto;
use namespace Nuxed\Crypto\Binary;
use namespace Nuxed\Crypto\Asymmetric\Encryption;

final class PublicKey extends Encryption\Key {
  const int LENGTH = \SODIUM_CRYPTO_BOX_PUBLICKEYBYTES;
  public function __construct(Crypto\HiddenString $material) {
    if (Binary\length($material->toString()) !== static::LENGTH) {
      throw new Crypto\Exception\InvalidKeyException(
        'Encryption public key must be const(PublicKey::LENGTH) bytes long',
      );
    }

    parent::__construct($material);
  }
}
