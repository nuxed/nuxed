namespace Nuxed\Log\Handler;

use namespace Nuxed\Log;

interface IHandler {
  /**
   * Handles a record.
   *
   * All records may be passed to this method, and the handler should discard
   * those that it does not want to handle.
   *
   * The return value of this function controls the bubbling process of the handler stack.
   * Unless the bubbling is interrupted (by returning true), the Logger class will keep on
   * calling further handlers in the stack with a given log record.
   *
   * @return bool     true means that this handler handled the record, and that bubbling is not permitted.
   *         false means the record was either not processed or that this handler allows bubbling.
   */
  public function handle<<<__Enforceable>> reify T>(
    Log\LogLevel $level,
    string $message,
    KeyedContainer<string, T> $context,
  ): Awaitable<bool>;
}
