namespace Nuxed\Console\Formatter;

use namespace HH\Lib\Str;

/**
 * Escapes trailing "\" in given text.
 */
function escape_trailing_backslash(string $text): string {
  if (Str\ends_with($text, '\\')) {
    $len = Str\length($text);
    $text = Str\trim_right($text, '\\');
    $text = Str\replace("\0", '', $text);
    $text .= Str\repeat("\0", $len - Str\length($text));
  }

  return $text;
}
