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
use namespace Nuxed\EventDispatcher\Event;

/**
 * Allows to inspect input and output of a command.
 */
<<__Sealed(
  AfterExecuteEvent::class,
  BeforeExecuteEvent::class,
  ExceptionEvent::class,
)>>
abstract class Event implements Event\IEvent {
  public function __construct(
    protected Input\IInput $input,
    protected Output\IOutput $output,
    protected ?Command\Command $command,
  ) {}

  public function getInput(): Input\IInput {
    return $this->input;
  }

  public function getOutput(): Output\IOutput {
    return $this->output;
  }

  public function getCommand(): ?Command\Command {
    return $this->command;
  }
}
