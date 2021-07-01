/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Console\Formatter;

use namespace HH\Lib\Regex;

/**
 * Escapes "<" special char in given text.
 */
function escape(string $text): string {
  $text = Regex\replace($text, re"/([^\\\\]?)</", '$1\\<');
  return escape_trailing_backslash($text);
}
