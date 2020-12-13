namespace Nuxed\Log;

/**
 * A collecting logger that stacks logs for later.
 */
final class CollectingLogger extends AbstractLogger {
  private vec<shape(
    'level' => LogLevel,
    'message' => string,
    'context' => dict<string, mixed>,
  )> $logs = vec[];

  <<__Override>>
  public async function log<<<__Enforceable>> reify T>(
    LogLevel $level,
    string $message,
    KeyedContainer<string, T> $context = dict[],
  ): Awaitable<void> {
    $this->logs[] = shape(
      'level' => $level,
      'message' => $message,
      'context' => dict<string, T>($context),
    );
  }

  public function clean<<<__Enforceable>> reify T>(): Container<shape(
    'level' => LogLevel,
    'message' => string,
    'context' => KeyedContainer<string, T>,
  )> {
    $logs = $this->logs;
    $this->logs = vec[];

    $result = vec[];
    foreach ($logs as $log) {
      $context = dict[];
      foreach ($log['context'] as $key => $value) {
        $context[$key] = $value as T;
      }

      $result[] = shape(
        'level' => $log['level'],
        'message' => $log['message'],
        'context' => $context,
      );
    }

    return $result;
  }
}
