namespace Nuxed\Json;

use namespace Facebook\TypeSpec;

/**
 * Decoded a json encoded string, and assert, or coerce the type to the provided reified type.
 */
function typed<reify T>(string $json): T {
  return spec($json, TypeSpec\of<T>());
}
