namespace Nuxed\Console\Table;

use namespace HH\Lib\Str;
use namespace Nuxed\Console;

/**
 * The `AsciiTable` object with output a human readable ASCII table in of the
 * provided data.
 */
final class AsciiTable extends AbstractTable {
  /**
   * A string containing the output for a border.
   */
  protected ?string $border;

  /**
   * A dictonary containing necessary characters used for building the table.
   */
  protected dict<string, string> $characters = dict[
    'corner' => '+',
    'line' => '-',
    'header_line' => '=',
    'border' => '|',
    'padding' => ' ',
  ];

  /**
   * The integer length of the width each row should be.
   */
  protected int $rowWidth = 0;

  /**
   * Given a string value and a padding string, return the value with the pad
   * appended and prepended to the value.
   */
  protected function pad(string $value, string $pad = ''): string {
    return $pad.$value.$pad;
  }

  /**
   * Build a border for the width of the row width for the class and using the
   * class's `characters`.
   */
  protected function buildBorder(): string {
    if ($this->border is null) {
      $this->border = '+';

      foreach ($this->columnWidths as $width) {
        $this->border .= $this->characters['padding'];
        $this->border .= Str\repeat('-', $width);
        $this->border .= $this->characters['padding'];
        $this->border .= '+';
      }
    }

    return $this->border;
  }

  /**
   * Build a single cell of the table given the data and the key of the column
   * the data should go into.
   */
  protected function buildCell(string $value, int $key): string {
    $width = $this->columnWidths[$key];
    $value = Str\pad_right($value, $width);
    return $this->pad($value, $this->characters['padding']);
  }

  /**
   * Given a container of data, build a single row of the table.
   */
  protected function buildRow(Container<string> $data): string {
    $row = vec[];

    foreach (vec<string>($data) as $index => $value) {
      $row[] = $this->buildCell((string)$value, $index);
    }

    $row = $this->pad(
      Str\join($row, $this->characters['border']),
      $this->characters['border'],
    );

    return $row;
  }

  /**
   * Retrieve the width that each row in the table should be.
   */
  protected function getRowWidth(): int {
    if ($this->rowWidth is null) {
      if ($this->rows[0] is nonnull) {
        $this->rowWidth = Str\length($this->buildRow($this->rows[0]));
      }
    }

    return $this->rowWidth;
  }

  /**
   * Build the table and return its markup.
   */
  <<__Override>>
  public function render(): string {
    $output = vec[];

    $header = $this->buildRow($this->headers);
    if ($header) {
      $output[] = $this->buildBorder();
      $output[] = $header;
    }

    $output[] = $this->buildBorder();

    foreach ($this->rows as $row) {
      $output[] = $this->buildRow($row);
    }

    $output[] = $this->buildBorder();

    return Str\join($output, Console\Output\IOutput::EndOfLine);
  }
}
