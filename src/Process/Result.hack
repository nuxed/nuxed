namespace Nuxed\Process;

final class Result {
  public function __construct(
    private string $command,
    private Container<string> $arguments,
    private int $code,
    private string $output,
  ) {}

  public function getCommand(): string {
    return $this->command;
  }

  public function getArguments(): Container<string> {
    return $this->arguments;
  }

  public function isSuccess(): bool {
    return 0 === $this->getExitCode();
  }

  public function getExitCode(): int {
    return $this->code;
  }

  public function getOutput(bool $throwOnError = true): string {
    if ($throwOnError && !$this->isSuccess()) {
      throw new Exception\SubprocessException($this);
    }

    return $this->output;
  }
}
