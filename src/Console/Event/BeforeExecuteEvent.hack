/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Console\Event;

/**
 * Allows to do things before the command is executed, like skipping the command or changing the input.
 */
final class BeforeExecuteEvent extends Event {

  /**
   * Indicates if the command should be run or skipped.
   */
  private bool $commandShouldRun = true;

  /**
   * Disables the command, so it won't be run.
   */
  public function disableCommand(): void {
    $this->commandShouldRun = false;
  }

  /**
   * Enable the command, so it would run.
   */
  public function enableCommand(): void {
    $this->commandShouldRun = true;
  }

  /**
   * Returns true if the command is runnable, false otherwise.
   */
  public function commandShouldRun(): bool {
    return $this->commandShouldRun;
  }
}
