namespace Nuxed\Log\Processor;

use namespace Nuxed\Log;

interface IProcessor {
  public function process<<<__Enforceable>> reify T>(
    Log\LogLevel $level,
    string $message,
    KeyedContainer<string, T> $context,
  ): Awaitable<string>;
}
