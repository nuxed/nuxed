namespace Nuxed\Process\Exception;

use HH\Lib\Str;

final class FailedExecutionException extends RuntimeException {

  public function __construct(
    private string $command,
    private int $exit_code,
    private string $stdout_content,
    private string $stderr_content,
  ) {
    parent::__construct(
      Str\format('Failed executing "%s" (exit: %d)', $command, $exit_code),
      $exit_code,
    );
  }

  public function getCommand(): string {
    return $this->command;
  }

  public function getExitCode(): int {
    return $this->exit_code;
  }

  public function getStdoutContent(): string {
    return $this->stdout_content;
  }

  public function getStderrContent(): string {
    return $this->stderr_content;
  }
}
