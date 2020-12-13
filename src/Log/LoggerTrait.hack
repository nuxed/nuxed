namespace Nuxed\Log;

/**
 * This is a simple Logger trait that classes unable to extend AbstractLogger
 * (because they extend another class, etc) can include.
 *
 * It simply delegates all log-level-specific methods to the `log` method to
 * reduce boilerplate code that a simple Logger that does the same thing with
 * messages regardless of the error level has to implement.
 */
trait LoggerTrait implements ILogger {
  /**
   * System is unusable.
   */
  public async function emergency<<<__Enforceable>> reify T>(
    string $message,
    KeyedContainer<string, T> $context = dict[],
  ): Awaitable<void> {
    await $this->log<T>(LogLevel::EMERGENCY, $message, $context);
  }

  /**
   * Action must be taken immediately.
   *
   * Example: Entire website down, database unavailable, etc. This should
   * trigger the SMS alerts and wake you up.
   */
  public async function alert<<<__Enforceable>> reify T>(
    string $message,
    KeyedContainer<string, T> $context = dict[],
  ): Awaitable<void> {
    await $this->log<T>(LogLevel::ALERT, $message, $context);
  }

  /**
   * Critical conditions.
   *
   * Example: Application component unavailable, unexpected exception.
   */
  public async function critical<<<__Enforceable>> reify T>(
    string $message,
    KeyedContainer<string, T> $context = dict[],
  ): Awaitable<void> {
    await $this->log<T>(LogLevel::CRITICAL, $message, $context);
  }

  /**
   * Runtime errors that do not require immediate action but should typically
   * be logged and monitored.
   */
  public async function error<<<__Enforceable>> reify T>(
    string $message,
    KeyedContainer<string, T> $context = dict[],
  ): Awaitable<void> {
    await $this->log<T>(LogLevel::ERROR, $message, $context);
  }

  /**
   * Exceptional occurrences that are not errors.
   *
   * Example: Use of deprecated APIs, poor use of an API, undesirable things
   * that are not necessarily wrong.
   */
  public async function warning<<<__Enforceable>> reify T>(
    string $message,
    KeyedContainer<string, T> $context = dict[],
  ): Awaitable<void> {
    await $this->log<T>(LogLevel::WARNING, $message, $context);
  }

  /**
   * Normal but significant events.
   */
  public async function notice<<<__Enforceable>> reify T>(
    string $message,
    KeyedContainer<string, T> $context = dict[],
  ): Awaitable<void> {
    await $this->log<T>(LogLevel::NOTICE, $message, $context);
  }

  /**
   * Interesting events.
   *
   * Example: User logs in, SQL logs.
   */
  public async function info<<<__Enforceable>> reify T>(
    string $message,
    KeyedContainer<string, T> $context = dict[],
  ): Awaitable<void> {
    await $this->log<T>(LogLevel::INFO, $message, $context);
  }

  /**
   * Detailed debug information.
   */
  public async function debug<<<__Enforceable>> reify T>(
    string $message,
    KeyedContainer<string, T> $context = dict[],
  ): Awaitable<void> {
    await $this->log<T>(LogLevel::DEBUG, $message, $context);
  }
}
