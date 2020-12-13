namespace Nuxed\Console\Output;

use namespace Nuxed\Console\Formatter;

final class NullOutput extends AbstractOutput implements IConsoleOutput {
  public function __construct() {
    parent::__construct(Verbosity::QUIET, new Formatter\NullFormatter());
  }

  /**
   * {@inheritdoc}
   */
  <<__Override>>
  public function setFormatter(Formatter\IFormatter $_formatter): this {
    null;

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  <<__Override>>
  public function setVerbosity(Verbosity $_verbosity): this {
    null;

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  <<__Override>>
  public function getVerbosity(): Verbosity {
    return Verbosity::QUIET;
  }

  /**
   * {@inheritdoc}
   */
  <<__Override>>
  public async function write(
    string $_message,
    Verbosity $_verbosity = Verbosity::NORMAL,
    Type $_type = Type::NORMAL,
  ): Awaitable<void> {
    null;
  }

  /**
   * {@inheritdoc}
   */
  <<__Override>>
  public async function flush(): Awaitable<void> {
    null;
  }

  /**
   * Return the standard error output.
   */
  public function getErrorOutput(): IOutput {
    return new NullOutput();
  }
}
