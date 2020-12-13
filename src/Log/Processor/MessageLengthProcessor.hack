namespace Nuxed\Log\Processor;

use namespace Nuxed\Log;
use namespace HH\Lib\Str;

final class MessageLengthProcessor implements IProcessor {
  public function __construct(protected int $maxLength = 1024) {}

  public async function process<<<__Enforceable>> reify T>(
    Log\LogLevel $_level,
    string $message,
    KeyedContainer<string, T> $_context,
  ): Awaitable<string> {
    if (Str\length($message) <= $this->maxLength) {
      return $message;
    }

    return Str\slice($message, 0, $this->maxLength).'[...]';
  }
}
