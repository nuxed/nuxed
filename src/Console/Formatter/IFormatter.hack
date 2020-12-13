namespace Nuxed\Console\Formatter;

/**
 * Formatter interface for console output.
 */
interface IFormatter {
  /**
   * Adds a new style.
   */
  public function addStyle(string $name, Style\IStyle $style): this;

  /**
   * Checks if output formatter has style with specified name.
   */
  public function hasStyle(string $name): bool;

  /**
   * Gets style options from style with specified name.
   */
  public function getStyle(string $name): Style\IStyle;

  /**
   * Formats a message according to the given styles.
   */
  public function format(string $message): string;
}
