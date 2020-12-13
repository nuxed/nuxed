namespace Nuxed\Crypto\Symmetric;

use namespace Nuxed\Crypto;

<<__Sealed(Encryption\Key::class, Authentication\SignatureKey::class)>>
abstract class Key extends Crypto\Key {}
