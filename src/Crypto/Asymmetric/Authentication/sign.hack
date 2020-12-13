namespace Nuxed\Crypto\Asymmetric\Authentication;

/**
 * Sign a message with our private key
 */
function sign(string $message, Key\SignaturePrivateKey $key): string {
  return \sodium_crypto_sign_detached($message, $key->toString());
}
