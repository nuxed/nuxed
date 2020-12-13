namespace Nuxed\Console\Output\Sequence;

/**
 * @see http://ascii-table.com/ansi-escape-sequences.php
 */
enum Erase: string as string {
  DISPLAY = "\033[2J";
  LINE = "\033[K";
}
