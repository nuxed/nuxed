namespace Nuxed\Json;

/**
 * Decode a json encoded string into a dynamic variable.
 */
function encode(mixed $value, bool $pretty = false, int $flags = 0): string {
  $flags |= \JSON_UNESCAPED_UNICODE |
    \JSON_UNESCAPED_SLASHES |
    \JSON_PRESERVE_ZERO_FRACTION;

  if ($pretty) {
    $flags |= \JSON_PRETTY_PRINT;
  }

  $error = null;
  $json = \json_encode_with_error($value, inout $error, $flags);
  if ($error is nonnull && \JSON_ERROR_NONE !== $error[0]) {
    throw new Exception\JsonEncodeException(Errors[$error[0]], $error[0]);
  }

  return $json;
}
