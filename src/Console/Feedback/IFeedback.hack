/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Console\Feedback;

/**
 * A `IFeedback` class handles the displaying of progress information to the user
 * for a specific task.
 */
interface IFeedback {
  /**
   * Progress the feedback display.
   */
  public function advance(int $increment = 1): Awaitable<void>;

  /**
   * Force the feedback to end its output.
   */
  public function finish(): Awaitable<void>;

  /**
   * Set the frequency the feedback should update.
   */
  public function setInterval(int $interval): this;

  /**
   * Set the message presented to the user to signify what the feedback
   * is referring to.
   */
  public function setMessage(string $message): this;

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
   * A template string used to construct additional information displayed before
   * the feedback indicator. The supported variables include message, percent,
   * elapsed, and estimated. These variables are denoted in the template '{:}'
   * notation. (i.e., '{:message} {:percent}').
   */
  public function setPrefix(string $prefix): this;

  /**
   * A template string used to construct additional information displayed after
   * the feedback indicator. The supported variables include message, percent,
   * elapsed, and estimated. These variables are denoted in the template '{:}'
   * notation. (i.e., '{:message} {:percent}').
   */
  public function setSuffix(string $suffix): this;

  /**
   * Set the total number of cycles (`advance` calls) the feedback should be
   * expected to take.
   */
  public function setTotal(int $total): this;
}
