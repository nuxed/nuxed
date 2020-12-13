namespace Nuxed\Crypto\Asymmetric\Authentication;

use namespace Nuxed\Crypto;
use namespace Nuxed\Crypto\Asymmetric;

<<__Sealed(Key\SignaturePublicKey::class, Key\SignaturePrivateKey::class)>>
abstract class SignatureKey extends Asymmetric\Key {
  final public static function private(
    Crypto\HiddenString $material,
  ): Key\SignaturePrivateKey {
    return new Key\SignaturePrivateKey($material);
  }

  final public static function public(
    Crypto\HiddenString $material,
  ): Key\SignaturePublicKey {
    return new Key\SignaturePublicKey($material);
  }

  final public static function generate(
  ): (Key\SignaturePrivateKey, Key\SignaturePublicKey) {
    // Encryption keypair
    $kp = \sodium_crypto_sign_keypair();
    $private = \sodium_crypto_sign_secretkey($kp);
    $public = \sodium_crypto_sign_publickey($kp);

    \sodium_memzero(inout $kp);
    return tuple(
      new Key\SignaturePrivateKey(new Crypto\HiddenString($private)),
      new Key\SignaturePublicKey(new Crypto\HiddenString($public)),
    );
  }
}
