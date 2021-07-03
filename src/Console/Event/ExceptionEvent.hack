/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Console\Event;

use namespace Nuxed\Console\{Command, Input, Output};

/**
 * Allows to handle throwables thrown while running a command.
 */
final class ExceptionEvent extends Event {
  private ?int $exitCode;

  public function __construct(
    Input\IInput $input,
    Output\IOutput $output,
    private \Exception $exception,
    ?Command\Command $command,
  ) {
    parent::__construct($input, $output, $command);
  }

  public function getException(): \Exception {
    return $this->exception;
  }

  public function setExitCode(int $exitCode): void {
    $this->exitCode = $exitCode;

    $r = new \ReflectionProperty($this->exception, 'code');
    $r->setAccessible(true);
    $r->setValue($this->exception, $this->exitCode);
  }

  public function getExitCode(): ?int {
    return $this->exitCode;
  }
}
