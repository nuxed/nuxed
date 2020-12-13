namespace Nuxed\Log;

/**
 * Describes a logger instance.
 *
 * The message MAY contain placeholders in the form: {foo} where foo
 * will be replaced by the context data in key "foo".
 *
 * The context container can contain arbitrary data. The only assumption that
 * can be made by implementors is that if an Exception instance is given
 * to produce a stack trace, it MUST be in a key named "exception".
 */
interface ILogger {
  /**
   * System is unusable.
   */
  public function emergency<<<__Enforceable>> reify T>(
    string $message,
    KeyedContainer<string, T> $context = dict[],
  ): Awaitable<void>;

  /**
   * Action must be taken immediately.
   *
   * Example: Entire website down, database unavailable, etc. This should
   * trigger the SMS alerts and wake you up.
   */
  public function alert<<<__Enforceable>> reify T>(
    string $message,
    KeyedContainer<string, T> $context = dict[],
  ): Awaitable<void>;

  /**
   * Critical conditions.
   *
   * Example: Application component unavailable, unexpected exception.
   */
  public function critical<<<__Enforceable>> reify T>(
    string $message,
    KeyedContainer<string, T> $context = dict[],
  ): Awaitable<void>;

  /**
   * Runtime errors that do not require immediate action but should typically
   * be logged and monitored.
   */
  public function error<<<__Enforceable>> reify T>(
    string $message,
    KeyedContainer<string, T> $context = dict[],
  ): Awaitable<void>;

  /**
   * Exceptional occurrences that are not errors.
   *
   * Example: Use of deprecated APIs, poor use of an API, undesirable things
   * that are not necessarily wrong.
   */
  public function warning<<<__Enforceable>> reify T>(
    string $message,
    KeyedContainer<string, T> $context = dict[],
  ): Awaitable<void>;

  /**
   * Normal but significant events.
   */
  public function notice<<<__Enforceable>> reify T>(
    string $message,
    KeyedContainer<string, T> $context = dict[],
  ): Awaitable<void>;

  /**
   * Interesting events.
   *
   * Example: User logs in, SQL logs.
   */
  public function info<<<__Enforceable>> reify T>(
    string $message,
    KeyedContainer<string, T> $context = dict[],
  ): Awaitable<void>;

  /**
   * Detailed debug information.
   */
  public function debug<<<__Enforceable>> reify T>(
    string $message,
    KeyedContainer<string, T> $context = dict[],
  ): Awaitable<void>;

  /**
   * Logs with an arbitrary level.
   */
  public function log<<<__Enforceable>> reify T>(
    LogLevel $level,
    string $message,
    KeyedContainer<string, T> $context = dict[],
  ): Awaitable<void>;
}
