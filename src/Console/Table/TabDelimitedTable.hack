/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Console\Table;

use namespace HH\Lib\Str;
use namespace Nuxed\Console;

/**
 * The `TabDelimitedTable` class builds and outputs a table with values tab-delimited
 * for use in other applications.
 */
final class TabDelimitedTable extends AbstractTable {
  /**
   * Build the table and return its markup.
   */
  <<__Override>>
  public function render(): string {
    $output = vec[];
    $output[] = Str\join($this->headers, "\t");

    foreach ($this->rows as $row) {
      $output[] = Str\join($row, "\t");
    }

    return Str\trim(Str\join($output, Console\Output\IOutput::EndOfLine));
  }
}
