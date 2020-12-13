namespace Nuxed\Console\Event;

use namespace Nuxed\Console\{Command, Input, Output};

/**
 * Allows to manipulate the exit code of a command after its execution.
 */
final class TerminateEvent extends Event {
  private int $exitCode;

  public function __construct(
    Input\IInput $input,
    Output\IOutput $output,
    ?Command\Command $command,
    int $exitCode,
  ) {
    parent::__construct($input, $output, $command);

    $this->exitCode = $exitCode;
  }

  public function setExitCode(int $exitCode): void {
    $this->exitCode = $exitCode;
  }

  public function getExitCode(): int {
    return $this->exitCode;
  }
}
