/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Console\UserInput;

use namespace Nuxed\Console;

/**
 * `AbstractUserInput` handles core functionality for prompting and accepting
 * the user input.
 */
abstract class AbstractUserInput<T> implements IUserInput<T> {
  /**
   * Input values accepted to continue.
   */
  protected dict<string, T> $acceptedValues = dict[];

  /**
   * Default value if input given is empty.
   */
  protected string $default = '';

  /**
   * If the input should be accepted strictly or not.
   */
  protected bool $strict = true;

  /**
   * Display position.
   */
  protected ?(int, int) $position = null;

  /**
   * Construct a new `UserInput` object.
   */
  public function __construct(
    /**
     * `Input` object used for retrieving user input.
     */
    protected Console\Input\IInput $input,

    /**
     * The output object used for sending output.
     */
    protected Console\Output\IOutput $output,
  ) {}

  /**
   * Set the display position (column, row).
   *
   * Implementation should not change position unless this method
   * is called.
   *
   * When changing positions, the implementation should always save the cursor
   * position, then restore it.
   */
  public function setPosition(?(int, int) $position): void {
    $this->position = $position;
  }

  /**
   * Set the values accepted by the user.
   */
  public function setAcceptedValues(
    KeyedContainer<string, T> $choices = dict[],
  ): this {
    $this->acceptedValues = dict<string, T>($choices);

    return $this;
  }

  /**
   * Set the default value to use when input is empty.
   */
  public function setDefault(string $default): this {
    $this->default = $default;

    return $this;
  }

  /**
   * Set if the prompt should run in strict mode.
   */
  public function setStrict(bool $strict): this {
    $this->strict = $strict;

    return $this;
  }
}
