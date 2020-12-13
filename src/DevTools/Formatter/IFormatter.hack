namespace Nuxed\DevTools\Formatter;

interface IFormatter {
  /**
   * Format the given code.
   */
  public function format(
    string $code,
    int $width = 80,
    int $indent = 2,
    bool $tabs = false,
  ): Awaitable<Result>;
}
