namespace Nuxed\Crypto\Symmetric\Authentication;

function authenticate(string $message, SignatureKey $key): string {
  return \sodium_crypto_generichash(
    $message,
    $key->toString(),
    \SODIUM_CRYPTO_GENERICHASH_BYTES_MAX,
  );
}
