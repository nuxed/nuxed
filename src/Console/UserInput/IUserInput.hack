/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Console\UserInput;

/**
 * User input handles presenting a prompt to the user and
 */
interface IUserInput<T> {
  /**
   * Set the display position (column, row).
   *
   * Implementation should not change position unless this method
   * is called.
   *
   * When changing positions, the implementation should always save the cursor
   * position, then restore it.
   */
  public function setPosition(?(int, int) $position): void;

  /**
   * Present the user with a prompt and return the inputted value.
   */
  public function prompt(string $message): Awaitable<T>;
}
