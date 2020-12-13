namespace Nuxed\Console\Output;

use namespace HH\Lib\Str;
use namespace Nuxed\Console\Exception;

/**
 * @see http://ascii-table.com/ansi-escape-sequences.php
 */
final class Cursor {
  public function __construct(private IOutput $output) {}

  /**
   * Move the cursor to the home position at
   * the upper-left corner of the screen (line 0, column 0).
   */
  public async function home(
    Verbosity $verbosity = Verbosity::NORMAL,
  ): Awaitable<void> {
    await $this->move(0, 0, $verbosity);
  }

  /**
   * Hide the cursor from the terminal.
   */
  public async function hide(
    Verbosity $verbosity = Verbosity::NORMAL,
  ): Awaitable<void> {
    await $this->output->write("\033[?25l", $verbosity);
  }

  /**
   * Show the cursor.
   */
  public async function show(
    Verbosity $verbosity = Verbosity::NORMAL,
  ): Awaitable<void> {
    await $this->output->write("\033[?25h", $verbosity);
  }

  /**
   * Save the current cursor position.
   */
  public async function save(
    Verbosity $verbosity = Verbosity::NORMAL,
  ): Awaitable<void> {
    await $this->sequence('s', $verbosity);
  }

  /**
   * Restore the cursor to it's previous position.
   */
  public async function restore(
    Verbosity $verbosity = Verbosity::NORMAL,
  ): Awaitable<void> {
    await $this->sequence('u', $verbosity);
  }

  /**
   * Move the cursor $n times up.
   */
  public async function up(
    int $n = 1,
    Verbosity $verbosity = Verbosity::NORMAL,
  ): Awaitable<void> {
    await $this->sequence('A', $verbosity, $n);
  }

  /**
   * Move the cursor $n times down.
   */
  public async function down(
    int $n = 1,
    Verbosity $verbosity = Verbosity::NORMAL,
  ): Awaitable<void> {
    await $this->sequence('B', $verbosity, $n);
  }

  /**
   * Move the cursor $n times forward.
   */
  public async function forward(
    int $n = 1,
    Verbosity $verbosity = Verbosity::NORMAL,
  ): Awaitable<void> {
    await $this->sequence('C', $verbosity, $n);
  }

  /**
   * Move the cursor $n times backward.
   */
  public async function backward(
    int $n = 1,
    Verbosity $verbosity = Verbosity::NORMAL,
  ): Awaitable<void> {
    await $this->sequence('D', $verbosity, $n);
  }

  /**
   * Moves the cursor to the specified position (coordinates).
   */
  public async function move(
    int $column,
    int $row,
    Verbosity $verbosity = Verbosity::NORMAL,
  ): Awaitable<void> {
    if ($row < 0 || $column < 0) {
      throw new Exception\InvalidArgumentException('Invalid coordinates.');
    }

    await $this->output
      ->write(Str\format("\033[%d;%dH", $row + 1, $column), $verbosity);
  }

  private async function sequence(
    string $sequence,
    Verbosity $verbosity = Verbosity::NORMAL,
    ?int $n = null,
  ): Awaitable<void> {
    if ($n is nonnull) {
      if ($n < 0) {
        throw new Exception\InvalidArgumentException(
          'Expected $n to be a positive integer.',
        );
      }

      await $this->output
        ->write(Str\format("\033[%d%s", $n, $sequence), $verbosity);
    } else {
      await $this->output
        ->write(Str\format("\033[%s", $sequence), $verbosity);
    }
  }
}
