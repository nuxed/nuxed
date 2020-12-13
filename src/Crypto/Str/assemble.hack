namespace Nuxed\Crypto\Str;

use namespace HH\Lib\{C, Str};

/**
 * Convert a container of integers to a string
 */
function assemble(Container<int> $chars): string {
  $args = vec<int>($chars);
  foreach ($args as $i => $v) {
    $args[$i] = (int)($v & 0xff);
  }

  return \pack(Str\repeat('C', C\count($args)), ...$args);
}
