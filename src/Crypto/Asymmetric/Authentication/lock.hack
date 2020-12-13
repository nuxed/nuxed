namespace Nuxed\Crypto\Asymmetric\Authentication;

use namespace Nuxed\Crypto;
use namespace Nuxed\Crypto\Asymmetric\Encryption;

function lock(
  Crypto\HiddenString $message,
  Key\SignaturePrivateKey $key,
  Encryption\Key\PublicKey $recipientPublicKey,
): string {
  $signature = sign($message->toString(), $key);
  $plaintext = new Crypto\HiddenString($signature.$message->toString());
  \sodium_memzero(inout $signature);
  $myEncKey = $key->toEncryptionKey();
  return Encryption\encrypt($plaintext, $myEncKey, $recipientPublicKey);
}
