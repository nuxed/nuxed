/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Process\Exception;

use namespace HH\Lib\Str;

final class FailedExecutionException extends RuntimeException {

  public function __construct(
    private string $command,
    private int $exit_code,
    private string $stdout_content,
    private string $stderr_content,
  ) {
    parent::__construct(
      Str\format(
        'Failed executing "%s" (exit: %d)%s%s',
        $command,
        $exit_code,
        "\n",
        $stderr_content,
      ),
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
