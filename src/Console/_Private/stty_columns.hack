namespace Nuxed\Console\_Private;

/**
 * Runs and parses stty -a if it's available, suppressing any error output.
 */
<<__Memoize>>
async function get_stty_columns(): Awaitable<?string> {
  return await execute('stty -a | grep columns');
}
