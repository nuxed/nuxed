namespace Nuxed\Console\_Private;

use namespace HH\Lib\{Regex, Str};
use namespace Nuxed\Console\Exception;

/**
 * Validates a command name.
 *
 * It must be non-empty and parts can optionally be separated by ":".
 */
function validate_command_name(string $name): void {
  if (!Regex\matches($name, re"/^[^\:]++(\:[^\:]++)*$/")) {
    throw new Exception\InvalidCharacterSequenceException(
      Str\format('Command name "%s" is invalid.', $name),
    );
  }
}
