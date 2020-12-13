namespace Nuxed\Log\Formatter;

use namespace Nuxed\Log;

interface IFormatter {
  public function format<<<__Enforceable>> reify T>(
    Log\LogLevel $level,
    string $message,
    KeyedContainer<string, T> $context,
  ): Awaitable<string>;
}
