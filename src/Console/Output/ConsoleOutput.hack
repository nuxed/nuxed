/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Console\Output;

use namespace HH\Lib\IO;
use namespace Nuxed\Console\Formatter;

final class ConsoleOutput
  extends AbstractOutputWrapper
  implements IConsoleOutput {
  /**
   * Standard error output.
   */
  private IOutput $stderr;

  /**
   * Construct a new `Output` object.
   */
  public function __construct(
    IO\WriteHandle $output,
    IO\WriteHandle $error,
    Verbosity $verbosity = Verbosity::NORMAL,
    ?Formatter\IFormatter $formatter = null,
  ) {
    $output = new Output($output, $verbosity, $formatter);
    parent::__construct($output);

    $this->stderr = new Output($error, $verbosity, $formatter);
  }

  /**
   * Set the formatter instance.
   */
  <<__Override>>
  public function setFormatter(Formatter\IFormatter $formatter): this {
    $this->output->setFormatter($formatter);
    $this->stderr->setFormatter($formatter);

    return $this;
  }

  /**
   * Set the global verbosity of the `Output`.
   */
  <<__Override>>
  public function setVerbosity(Verbosity $verbosity): this {
    $this->output->setVerbosity($verbosity);
    $this->stderr->setVerbosity($verbosity);

    return $this;
  }

  public function getErrorOutput(): IOutput {
    return $this->stderr;
  }
}
