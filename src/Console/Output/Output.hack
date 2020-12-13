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
