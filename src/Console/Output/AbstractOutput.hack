/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Console\Output;

use namespace HH\Lib\{IO, Str};
use namespace Nuxed\Console\Formatter;

abstract class AbstractOutput implements IOutput {
  /**
   * The global verbosity level for the `Output`.
   */
  protected Verbosity $verbosity;

  /**
   * The formatter instance.
   */
  protected Formatter\IFormatter $formatter;

  /**
   * The output cursor.
   */
  protected ?Cursor $cursor = null;

  private ?Awaitable<void> $writeQueue = null;

  /**
   * Construct a new `Output` object.
   */
  public function __construct(
    Verbosity $verbosity = Verbosity::NORMAL,
    ?Formatter\IFormatter $formatter = null,
  ) {
    $this->verbosity = $verbosity;
    $this->formatter = $formatter ?? new Formatter\Formatter();
  }

  /**
   * {@inheritdoc}
   */
  public function format(string $message, Type $type = Type::NORMAL): string {
    switch ($type) {
      case Type::NORMAL:
        return $this->formatter->format($message);
      case Type::RAW:
        return $message;
      case Type::PLAIN:
        return \strip_tags($message);
    }
  }

  /**
   * {@inheritdoc}
   */
  final public async function writeln(
    string $message,
    Verbosity $verbosity = Verbosity::NORMAL,
    Type $type = Type::NORMAL,
  ): Awaitable<void> {
    await $this->write($message.IOutput::EndOfLine, $verbosity, $type);
  }

  /**
   * {@inheritdoc}
   */
  public function getCursor(): Cursor {
    if ($this->cursor is null) {
      $this->cursor = new Cursor($this);
    }

    return $this->cursor;
  }

  /**
   * @internal
   */
  protected async function writeTo(
    IO\WriteHandle $handle,
    string $message,
    Verbosity $verbosity,
    Type $type = Type::NORMAL,
  ): Awaitable<void> {
    $this->writeQueue = async {
      if (!$this->shouldOutput($verbosity)) {
        return;
      }

      await $this->writeQueue;
      await $handle->writeAllAsync($this->format($message, $type));

      return;
    };
  }

  /**
   * {@inheritdoc}
   */
  public async function erase(
    Sequence\Erase $mode = Sequence\Erase::LINE,
  ): Awaitable<void> {
    $string = Str\format('%s%s', IOutput::Ctrl, $mode);

    await $this->write($string);
  }

  /**
   * {@inheritdoc}
   */
  <<__Override>>
  public async function flush(): Awaitable<void> {
    $queue = $this->writeQueue;
    $this->writeQueue = null;
    await $queue;
  }

  /**
   * {@inheritdoc}
   */
  public function setFormatter(Formatter\IFormatter $formatter): this {
    $this->formatter = $formatter;

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  public function getFormatter(): Formatter\IFormatter {
    return $this->formatter;
  }

  /**
   * {@inheritdoc}
   */
  public function setVerbosity(Verbosity $verbosity): this {
    $this->verbosity = $verbosity;

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  public function getVerbosity(): Verbosity {
    return $this->verbosity;
  }

  /**
   * Determine how the given verbosity compares to the class's verbosity level.
   */
  protected function shouldOutput(Verbosity $verbosity): bool {
    return ($verbosity as int <= $this->verbosity as int);
  }
}
