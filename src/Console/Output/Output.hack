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

final class Output extends AbstractOutput {
  private IO\WriteHandle $handle;

  /**
   * Construct a new `Output` object.
   */
  public function __construct(
    IO\WriteHandle $handle,
    Verbosity $verbosity = Verbosity::NORMAL,
    ?Formatter\IFormatter $formatter = null,
  ) {
    $this->handle = $handle;

    parent::__construct($verbosity, $formatter);
  }

  /**
   * {@inheritdoc}
   */
  <<__Override>>
  public async function write(
    string $message,
    Verbosity $verbosity = Verbosity::NORMAL,
    Type $type = Type::NORMAL,
  ): Awaitable<void> {
    await $this->writeTo($this->handle, $message, $verbosity, $type);
  }
}
