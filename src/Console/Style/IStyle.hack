/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Console\Style;

use namespace Nuxed\Console\{Feedback, Output, Table, Tree, UserInput};

interface IStyle {

  /**
  * Formats a message as a block of text.
  */
  public function block(
    string $message,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
    ?string $type = null,
    ?string $style = null,
    string $prefix = '',
    bool $padding = false,
    bool $escape = true,
    bool $indent = true,
  ): Awaitable<void>;

  /**
   * Formats a command title.
   */
  public function title(
    string $message,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
  ): Awaitable<void>;

  /**
   * Formats a section title.
   */
  public function section(
    string $message,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
  ): Awaitable<void>;

  /**
   * Formats informational text.
   */
  public function text(
    string $message,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
  ): Awaitable<void>;

  /**
   * Formats a success result bar.
   */
  public function success(
    string $message,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
  ): Awaitable<void>;

  /**
   * Formats an error result bar.
   */
  public function error(
    string $message,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
  ): Awaitable<void>;

  /**
   * Formats an warning result bar.
   */
  public function warning(
    string $message,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
  ): Awaitable<void>;

  /**
   * Formats a note admonition.
   */
  public function note(
    string $message,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
  ): Awaitable<void>;

  /**
   * Formats a caution admonition.
   */
  public function caution(
    string $message,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
  ): Awaitable<void>;

  /**
   * Add a newline(s).
   */
  public function nl(
    int $count = 1,
    Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
  ): Awaitable<void>;

  /**
   * Construct and return a new `Tree` object.
   */
  public function tree<Tk as arraykey, Tv>(
    KeyedContainer<Tk, Tv> $elements,
  ): Tree\ITree<Tk, Tv>;

  /**
   * Construct and return a new `Table` object.
   */
  public function table(): Table\ITable;

  /**
   * Construct and return a new `Confirm` object given the default answer.
   */
  public function confirm(string $default = ''): UserInput\Confirm;

  /**
   * Construct and return a new `Menu` object given the choices and display
   * message.
   */
  public function menu(KeyedContainer<string, string> $choices): UserInput\Menu;

  /**
   * Construct and return a new instance of `ProgressBarFeedback`.
   */
  public function progress(
    int $total,
    string $message = '',
    int $interval = 100,
  ): Feedback\ProgressBarFeedback;

  /**
   * Construct and return a new `WaitFeedback` object.
   *
   * @param int    $total     The total number of cycles of the process
   * @param string $message   The message presented with the feedback
   * @param int    $interval  The time interval the feedback should update
   */
  public function wait(
    int $tota,
    string $message = '',
    int $interval = 100,
  ): Feedback\WaitFeedback;
}
