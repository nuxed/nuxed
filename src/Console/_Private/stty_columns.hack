namespace Nuxed\Console\_Private;

use namespace Nuxed\Process;

/**
 * Runs and parses stty -a if it's available, suppressing any error output.
 */
<<__Memoize>>
async function get_stty_columns(): Awaitable<?string> {
  $result = await Process\execute('stty', '-a', '|', 'grep', 'columns');
  if (!$result->isSuccess()) {
    return null;
  }

  return $result->getOutput();
}
