namespace Nuxed\Console\Exception;

use namespace Nuxed\Console\Command;

/**
 * Exception thrown when an invalid command name is provided to the application.
 */
final class CommandNotFoundException
  extends \RuntimeException
  implements Exception {

  <<__Pure, __MaybeMutable, __Override>>
  public function getCode(): int {
    return Command\ExitCode::COMMAND_NOT_FOUND;
  }
}
