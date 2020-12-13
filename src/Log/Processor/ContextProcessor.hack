namespace Nuxed\Log\Processor;

use namespace Nuxed\Log;
use namespace HH\Lib\Str;

final class ContextProcessor implements IProcessor {
  public async function process<<<__Enforceable>> reify T>(
    Log\LogLevel $_level,
    string $message,
    KeyedContainer<string, T> $context,
  ): Awaitable<string> {
    if (!Str\contains($message, '}')) {
      return $message;
    }

    foreach ($context as $key => $value) {
      $placeholder = '{'.$key.'}';

      if (!Str\contains($message, $placeholder)) {
        continue;
      }

      $message = Str\replace(
        $message,
        $placeholder,
        Log\_Private\stringify($value),
      );
    }

    return $message;
  }
}
