namespace Nuxed\Serializer;

/**
 * Serializes/Unserializes Hack values.
 *
 * Implementations of this interface MUST deal with errors carefully. They MUST
 * also deal with forward and backward compatibility at the storage format level.
 */
interface ISerializer {
  /**
   * Serialize a value.
   *
   * When serialization fails, no exception should be
   * thrown. Instead, this method should return null.
   */
  public function serialize<<<__Enforceable>> reify T>(T $value): ?string;

  /**
   * Unserializes a single value and throws and exception if anything goes wrong.
   */
  public function unserialize<<<__Enforceable>> reify T>(string $value): T;
}
