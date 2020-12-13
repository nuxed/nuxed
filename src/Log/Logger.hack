namespace Nuxed\Log;

final class Logger extends AbstractLogger {
  public function __construct(
    public Container<Handler\IHandler> $handlers,
    public Container<Processor\IProcessor> $processors,
  ) {}

  <<__Override>>
  public async function log<<<__Enforceable>> reify T>(
    LogLevel $level,
    string $message,
    KeyedContainer<string, T> $context = dict[],
  ): Awaitable<void> {
    $lastOperation = async {
      return $message;
    };

    foreach ($this->processors as $processor) {
      $lastOperation = async {
        $message = await $lastOperation;

        return await $processor->process<T>($level, $message, $context);
      };
    }

    $message = await $lastOperation;
    $lastOperation = async {
      return false;
    };

    foreach ($this->handlers as $handler) {
      $lastOperation = async {
        if (await $lastOperation) {
          return true;
        }

        return await $handler->handle<T>($level, $message, $context);
      };
    }

    await $lastOperation;
  }
}
