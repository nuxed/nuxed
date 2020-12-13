namespace Nuxed\Crypto;

use namespace Nuxed\Crypto;
use namespace Nuxed\Crypto\{Exception, Str};
use namespace HH\Lib\SecureRandom;

/**
 * Base class for all cryptography keys
 */
<<__Sealed(Symmetric\Key::class, Asymmetric\Key::class), __ConsistentConstruct>>
abstract class Key {
  protected static int $prefixTagLength = 12;

  protected string $material;

  abstract const int LENGTH;

  public function __construct(Crypto\HiddenString $material) {
    $this->material = Str\copy($material->toString());
  }

  /**
   * Hide this from var_dump(), etc.
   */
  public function __debugInfo(): dict<string, string> {
    return dict[
      'material' => '*',
      'attention' => 'If you need the value of a Crypto Key, '.
        'invoke toString() instead of dumping it.',
    ];
  }

  /**
   * Don't allow this object to ever be cloned
   */
  public function __clone(): void {
    throw new Exception\UnclonableException('Crypto key cannot be cloned.');
  }

  /**
   * Don't allow this object to ever be serialized
   */
  public function __sleep(): void {
    throw new Exception\UnserializableException();
  }

  /**
   * Don't allow this object to ever be unserialized
   */
  public function __wakeup(): void {
    throw new Exception\UnserializableException();
  }

  /**
   * Get the actual key material
   */
  public function toString(): string {
    return Str\copy($this->material);
  }

  /**
   * Export a cryptography key to a string (with a checksum).
   */
  public function export(): HiddenString {
    $data = $this->toString();
    $prefix = SecureRandom\string(self::$prefixTagLength);
    $hidden = new HiddenString(Hex\encode(
      $prefix.
      $data.
      \sodium_crypto_generichash(
        $prefix.$data,
        '',
        \SODIUM_CRYPTO_GENERICHASH_BYTES_MAX,
      ),
    ));
    // wipe key material
    \sodium_memzero(inout $data);
    return $hidden;
  }

  /**
   * Load a key from a string.
   */
  public static function import(HiddenString $data): this {
    return new static(new HiddenString(
      static::getKeyDataFromString(Hex\decode($data->toString())),
    ));
  }

  /**
   * Take a stored key string, get the derived key (after verifying the
   * checksum)
   */
  protected static function getKeyDataFromString(string $data): string {
    $prefixTag = Binary\slice($data, 0, self::$prefixTagLength);
    $keyData = Binary\slice(
      $data,
      self::$prefixTagLength,
      -\SODIUM_CRYPTO_GENERICHASH_BYTES_MAX,
    );
    $checksum = Binary\slice(
      $data,
      -\SODIUM_CRYPTO_GENERICHASH_BYTES_MAX,
      \SODIUM_CRYPTO_GENERICHASH_BYTES_MAX,
    );
    $calc = \sodium_crypto_generichash(
      $prefixTag.$keyData,
      '',
      \SODIUM_CRYPTO_GENERICHASH_BYTES_MAX,
    );
    if (!\hash_equals($calc, $checksum)) {
      throw new Exception\InvalidKeyException('Checksum validation fail');
    }
    \sodium_memzero(inout $data);
    \sodium_memzero(inout $prefixTag);
    \sodium_memzero(inout $calc);
    \sodium_memzero(inout $checksum);
    return $keyData;
  }
}
