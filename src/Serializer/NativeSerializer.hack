namespace Nuxed\Serializer;

final class NativeSerializer implements ISerializer {
  /**
   * Serialize a value.
   *
   * When serialization fails, no exception should be
   * thrown. Instead, this method should return null.
   */
  public function serialize<<<__Enforceable>> reify T>(T $value): ?string {
    try {
      $val = \serialize($value);
      if (false === $val) {
        return null;
      }

      return $val as string;
    } catch (\Throwable $e) {
      return null;
    }
  }

  /**
   * Unserializes a single value and throws and exception if anything goes wrong.
   */
  public function unserialize<<<__Enforceable>> reify T>(string $value): T {
    if ('b:0;' === $value) {
      return false as T;
    }

    if ('b:1;' === $value) {
      return true as T;
    }

    if ('N;' === $value) {
      return null as T;
    }

    try {
      $unserialized = \unserialize($value);

      if (false !== $unserialized) {
        return $unserialized as T;
      }

      $error = \error_get_last();
      $message = (false === $error) || ($error['message'] is null)
        ? 'Failed to unserialize values'
        : $error['message'] as string;
      throw new \DomainException($message);
    } catch (\Error $e) {
      throw new \ErrorException(
        $e->getMessage(),
        (int)$e->getCode(),
        \E_ERROR,
        $e->getFile(),
        $e->getLine(),
      );
    }
  }
}
