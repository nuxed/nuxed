namespace Nuxed\Console\Formatter;

/**
 * Formatter interface for console output that supports word wrapping.
 */
interface IWrappableFormatter extends IFormatter {
  /**
   * Formats a message according to the given styles, wrapping at `$width` (0 means no wrapping).
   */
  public function format(string $message, int $width = 0): string;
}
