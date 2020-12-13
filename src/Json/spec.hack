namespace Nuxed\Json;

use namespace Facebook\{TypeAssert, TypeSpec};

/**
 * Decoded a json encoded string, and assert, or coerce the type to the provided type spec.
 */
function spec<T>(string $json, TypeSpec\TypeSpec<T> $spec): T {
  $value = decode($json);

  try {
    return $spec->assertType($value);
  } catch (TypeAssert\IncorrectTypeException $e) {
    return $spec->coerceType($value);
  } catch (TypeAssert\TypeCoercionException $e) {
    throw new Exception\JsonDecodeException(
      $e->getMessage(),
      $e->getCode(),
      $e,
    );
  }
}
