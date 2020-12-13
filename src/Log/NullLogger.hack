namespace Nuxed\Log;

/**
 * This Logger can be used to avoid conditional log calls.
 *
 * Logging should always be optional, and if no logger is provided to your
 * library creating a NullLogger instance to have something to throw logs at
 * is a good way to avoid littering your code with `if ($this->logger) { }`
 * blocks.
 */
final class NullLogger extends AbstractLogger {
  /**
   * Logs with an arbitrary level.
   */
  <<__Override>>
  public async function log<<<__Enforceable>> reify T>(
    LogLevel $_level,
    string $_message,
    KeyedContainer<string, T> $_context = dict[],
  ): Awaitable<void> {
    // noop
  }
}
