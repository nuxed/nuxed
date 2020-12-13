namespace Nuxed\Crypto\Str;

use namespace Nuxed\Crypto\{Binary, Exception};

/**
 * Calculate A xor B, given two binary strings of the same length.
 */
function xor(string $right, string $left): string {
  $length = Binary\length($left);
  if ($length !== Binary\length($right)) {
    throw new Exception\InvalidArgumentException(
      'Both strings must be the same length',
    );
  }

  if ($length < 1) {
    return '';
  }

  $left = vec<int>(disassemble($left));
  $right = vec<int>(disassemble($right));
  $result = vec[];
  foreach ($left as $i => $_c) {
    $result[] = $left[$i] ^ $right[$i];
  }

  return assemble($result);
}
