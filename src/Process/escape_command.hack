namespace Nuxed\Process;

use function escapeshellcmd;

/**
 * Escape shell metacharacters.
 */
function escape_command(string $argument): string {
  return escapeshellcmd($argument);
}
