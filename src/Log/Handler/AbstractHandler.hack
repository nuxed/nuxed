namespace Nuxed\Log\Handler;

use namespace Nuxed\Log;
use namespace Nuxed\Log\Formatter;

abstract class AbstractHandler implements IHandler {
  const dict<Log\LogLevel, int> LEVELS = dict[
    Log\LogLevel::DEBUG => 0,
    Log\LogLevel::INFO => 1,
    Log\LogLevel::NOTICE => 2,
    Log\LogLevel::WARNING => 3,
    Log\LogLevel::ERROR => 4,
    Log\LogLevel::CRITICAL => 5,
    Log\LogLevel::ALERT => 6,
    Log\LogLevel::EMERGENCY => 7,
  ];

  protected Formatter\IFormatter $formatter;

  /**
   * @param Log\LogLevel   $level  The minimum logging level at which this handler will be triggered
   * @param bool       $bubble Whether the messages that are handled can bubble up the stack or not
   */
  public function __construct(
    ?Formatter\IFormatter $formatter = null,
    protected Log\LogLevel $level = Log\LogLevel::DEBUG,
    protected bool $bubble = true,
  ) {
    $this->formatter = $formatter ?? new Formatter\LineFormatter();
  }

  public async function handle<<<__Enforceable>> reify T>(
    Log\LogLevel $level,
    string $message,
    KeyedContainer<string, T> $context,
  ): Awaitable<bool> {
    if (static::LEVELS[$this->level] > static::LEVELS[$level]) {
      return false;
    }

    $message = await $this->formatter->format<T>($level, $message, $context);

    await $this->write($message);

    return false === $this->bubble;
  }

  /**
   * Writes the messenge down to the log of the implementing handler
   */
  abstract protected function write(string $message): Awaitable<void>;
}
