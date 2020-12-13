namespace Nuxed\Translation\Formatter;

interface IMessageFormatter {
  /**
   * Formats a localized message pattern with given arguments.
   */
  public function format<<<__Enforceable>> reify T>(
    string $message,
    string $locale,
    KeyedContainer<string, T> $parameters = dict[],
  ): Awaitable<string>;
}
