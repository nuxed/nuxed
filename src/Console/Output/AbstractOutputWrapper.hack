/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Console\Output;

use namespace Nuxed\Console\Formatter;

abstract class AbstractOutputWrapper implements IOutput {
  /**
   * Construct a new `AbstractOutputWrapper` object.
   */
  public function __construct(protected IOutput $output) {}

  /**
   * Format contents by parsing the style tags and applying necessary formatting.
   */
  public function format(string $message, Type $type = Type::NORMAL): string {
    return $this->output->format($message, $type);
  }

  /**
   * Send output to the standard output stream.
   */
  public function write(
    string $message,
    Verbosity $verbosity = Verbosity::NORMAL,
    Type $type = Type::NORMAL,
  ): Awaitable<void> {
    return $this->output->write($message, $verbosity, $type);
  }

  /**
   * Send output to the standard output stream with a new line charachter appended to the message.
   */
  public function writeln(
    string $message,
    Verbosity $verbosity = Verbosity::NORMAL,
    Type $type = Type::NORMAL,
  ): Awaitable<void> {
    return $this->output->writeln($message, $verbosity, $type);
  }

  /**
   * Get the output cursor.
   */
  public function getCursor(): Cursor {
    return $this->output->getCursor();
  }

  /**
   * Clears all characters
   */
  public function erase(
    Sequence\Erase $mode = Sequence\Erase::LINE,
  ): Awaitable<void> {
    return $this->output->erase($mode);
  }

  /**
   * Flush the output.
   */
  public function flush(): Awaitable<void> {
    return $this->output->flush();
  }

  /**
   * Set the formatter instance.
   */
  public function setFormatter(Formatter\IFormatter $formatter): this {
    $this->output->setFormatter($formatter);

    return $this;
  }

  /**
   * Returns the formatter instance.
   */
  public function getFormatter(): Formatter\IFormatter {
    return $this->output->getFormatter();
  }

  /**
   * Set the global verbosity of the `Output`.
   */
  public function setVerbosity(Verbosity $verbosity): this {
    $this->output->setVerbosity($verbosity);
    return $this;
  }

  /**
   * Get the global verbosity of the `Output`.
   */
  public function getVerbosity(): Verbosity {
    return $this->output->getVerbosity();
  }
}
