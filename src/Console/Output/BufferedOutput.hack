namespace Nuxed\Console\Output;

final class BufferedOutput extends AbstractOutput {
  private string $stdout = '';

  /**
   * {@inheritdoc}
   */
  <<__Override>>
  public async function write(
    string $message,
    Verbosity $verbosity = Verbosity::NORMAL,
    Type $type = Type::NORMAL,
  ): Awaitable<void> {
    if (!$this->shouldOutput($verbosity)) {
      return;
    }

    $this->stdout .= $this->format($message, $type);
  }


  public function fetch(): string {
    $content = $this->stdout;
    $this->stdout = '';

    return $content;
  }
}
