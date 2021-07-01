/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Process;

use namespace HH\Lib\{Regex, Str};

use const DIRECTORY_SEPARATOR;

/**
 * Escape a string to be used as a shell argument.
 */
function escape_argument(string $argument)[]: string {
  /**
   * The following code was copied ( with modification ) from the Symfony Process Component (v5.2.3 - 2021-02-22).
   *
   * https://github.com/symfony/process/blob/b8d6eff26e48187fed15970799f4b605fa7242e4/Process.php#L1623-L1643
   *
   * @license MIT
   *
   * @see https://github.com/symfony/process/blob/b8d6eff26e48187fed15970799f4b605fa7242e4/LICENSE
   *
   * @copyright (c) 2004-2021 Fabien Potencier <fabien@symfony.com>
   */
  if ('' === $argument) {
    return '""';
  }

  if ('\\' !== DIRECTORY_SEPARATOR) {
    $argument = Str\replace($argument, "'", "'\\''");

    return "'".$argument."'";
  }

  if (Str\contains($argument, "\0")) {
    $argument = Str\replace($argument, "\0", '?');
  }

  if (!Regex\matches($argument, re'/[\/()%!^"<>&|\s]/')) {
    return $argument;
  }

  $argument = Regex\replace($argument, re'/(\\\\+)$/', '$1$1');
  $argument = Str\replace_every($argument, dict[
    '"' => '""',
    '^' => '"^^"',
    '%' => '"^%"',
    '!' => '"^!"',
    "\n" => '!LF!',
  ]);

  return '"'.$argument.'"';
}
