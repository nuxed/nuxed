namespace Nuxed\Console\Formatter;

use namespace HH\Lib\Regex;

/**
 * Escapes "<" special char in given text.
 */
function escape(string $text): string {
  $text = Regex\replace($text, re"/([^\\\\]?)</", '$1\\<');
  return escape_trailing_backslash($text);
}
