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

interface IOutput {
  const string Tab = "\t";
  const string EndOfLine = \PHP_EOL;
  const string Ctrl = "\r";

  /**
   * Format contents by parsing the style tags and applying necessary formatting.
   */
  public function format(string $message, Type $type = Type::NORMAL): string;

  /**
   * Send output to the standard output stream.
   */
  public function write(
    string $message,
    Verbosity $verbosity = Verbosity::NORMAL,
    Type $type = Type::NORMAL,
  ): Awaitable<void>;

  /**
   * Send output to the standard output stream with a new line charachter appended to the message.
   */
  public function writeln(
    string $message,
    Verbosity $verbosity = Verbosity::NORMAL,
    Type $type = Type::NORMAL,
  ): Awaitable<void>;

  /**
   * Get the output cursor.
   */
  public function getCursor(): Cursor;

  /**
   * Clears all characters
   */
  public function erase(
    Sequence\Erase $mode = Sequence\Erase::LINE,
  ): Awaitable<void>;

  /**
   * Flush the output.
   */
  public function flush(): Awaitable<void>;

  /**
   * Set the formatter instance.
   */
  public function setFormatter(Formatter\IFormatter $formatter): this;

  /**
   * Returns the formatter instance.
   */
  public function getFormatter(): Formatter\IFormatter;

  /**
   * Set the global verbosity of the `Output`.
   */
  public function setVerbosity(Verbosity $verbosity): this;

  /**
   * Get the global verbosity of the `Output`.
   */
  public function getVerbosity(): Verbosity;
}
