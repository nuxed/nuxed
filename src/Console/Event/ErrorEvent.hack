namespace Nuxed\Console\Event;

use namespace Nuxed\Console\{Command, Input, Output};

/**
 * Allows to handle throwables thrown while running a command.
 */
final class ErrorEvent extends Event {
  private ?int $exitCode;

  public function __construct(
    Input\IInput $input,
    Output\IOutput $output,
    private \Throwable $error,
    ?Command\Command $command,
  ) {
    parent::__construct($input, $output, $command);
  }

  public function getError(): \Throwable {
    return $this->error;
  }

  public function setError(\Throwable $error): void {
    $this->error = $error;
  }

  public function setExitCode(int $exitCode): void {
    $this->exitCode = $exitCode;

    $r = new \ReflectionProperty($this->error, 'code');
    $r->setAccessible(true);
    $r->setValue($this->error, $this->exitCode);
  }

  public function getExitCode(): ?int {
    return $this->exitCode;
  }
}
