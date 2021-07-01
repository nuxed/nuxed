/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Console\_Private;

use namespace Nuxed\Process;

/**
 * Runs and parses stty -a if it's available, suppressing any error output.
 */
<<__Memoize>>
async function get_stty_columns(): Awaitable<?string> {
  try {
    list($content, $_) = await Process\execute(
      'stty',
      vec['-a', '|', 'grep', 'columns'],
      null,
      dict[],
      false,
    );

    return $content;
  } catch (Process\Exception\FailedExecutionException $e) {
    return null;
  }
}
