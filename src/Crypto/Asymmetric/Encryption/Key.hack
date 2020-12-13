namespace Nuxed\Crypto\Asymmetric\Encryption;

use namespace Nuxed\Crypto;
use namespace Nuxed\Crypto\Asymmetric;

<<__Sealed(Key\PublicKey::class, Key\PrivateKey::class)>>
abstract class Key extends Asymmetric\Key {
  /**
   * Diffie-Hellman, ECDHE, etc.
   *
   * Get a shared key from a private key you possess and a public key for
   * the intended message recipient
   */
  final public static function shared(
    Key\PrivateKey $private,
    Key\PublicKey $public,
  ): Crypto\HiddenString {
    return new Crypto\HiddenString(
      \sodium_crypto_scalarmult($private->toString(), $public->toString()),
    );
  }

  final public static function private(
    Crypto\HiddenString $material,
  ): Key\PrivateKey {
    return new Key\PrivateKey($material);
  }

  final public static function public(
    Crypto\HiddenString $material,
  ): Key\PublicKey {
    return new Key\PublicKey($material);
  }

  final public static function generate(): (Key\PrivateKey, Key\PublicKey) {
    // Encryption keypair
    $kp = \sodium_crypto_box_keypair();
    $private = \sodium_crypto_box_secretkey($kp);
    $public = \sodium_crypto_box_publickey($kp);

    \sodium_memzero(inout $kp);
    return tuple(
      new Key\PrivateKey(new Crypto\HiddenString($private)),
      new Key\PublicKey(new Crypto\HiddenString($public)),
    );
  }
}
