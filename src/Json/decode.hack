namespace Nuxed\Json;

/**
 * Decode a json encoded string into a dynamic variable.
 */
function decode(string $json, bool $assoc = true)[]: dynamic {
  try {
    $error = null;
    $value = \json_decode_with_error(
      $json,
      inout $error,
      $assoc,
      512,
      \JSON_BIGINT_AS_STRING | \JSON_FB_HACK_ARRAYS,
    );
  } catch (\Error $e) {
    // assoc = true & invalid property name results in `\Error`
    throw new Exception\JsonDecodeException(
      $e->getMessage(),
      (int)$e->getCode(),
    );
  }

  if ($error is nonnull && \JSON_ERROR_NONE !== $error[0]) {
    throw new Exception\JsonDecodeException(Errors[$error[0]], $error[0]);
  }

  return $value;
}
