namespace Nuxed\Console\Table;

use namespace HH\Lib\{C, Str};

/**
 * The `AbstractTable` class provides the core functionality for building and
 * displaying tabular data.
 */
abstract class AbstractTable implements ITable {
  /**
   * Data structure that holds the width of each column.
   */
  protected vec<int> $columnWidths = vec[];

  /**
   * Data structure holding the header names of each column.
   */
  protected Container<string> $headers = vec[];

  /**
   * Data structure holding the data for each row in the table.
   */
  protected vec<vec<string>> $rows = vec[];

  /**
   * Append a new row of data to the end of the existing rows.
   */
  public function addRow(Container<string> $row): this {
    $this->setColumnWidths($row);
    $this->rows[] = vec($row);

    return $this;
  }

  /**
   * Given the row of data, adjust the column width accordingly so that the
   * columns width is that of the maximum data field size.
   */
  protected function setColumnWidths(Container<string> $row): void {
    foreach (vec($row) as $index => $value) {
      $width = Str\length($value);
      $currentWidth = $this->columnWidths[$index] ?? 0;

      if ($width > $currentWidth) {
        if (C\count($this->columnWidths) === $index) {
          $this->columnWidths[] = $width;
        } else {
          $this->columnWidths[$index] = $width;
        }
      }
    }
  }

  /**
   * Set the data of the table with A container of column name and value containers.
   * This method overwrites any existing rows in the table.
   */
  public function setData(
    Container<KeyedContainer<string, string>> $data,
  ): this {
    $rows = vec[];
    $headers = vec[];

    foreach ($data as $row) {
      foreach ($row as $column => $_value) {
        if (!C\contains<string, string>($headers, $column)) {
          $headers[] = $column;
        }
      }

      $rows[] = $row;
    }

    $this->setRows($rows);
    $this->setHeaders($headers);

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  public function setHeaders(Container<string> $headers): this {
    $this->setColumnWidths($headers);
    $this->headers = $headers;

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  public function setRows(Container<Container<string>> $rows): this {
    $this->rows = vec[];

    foreach ($rows as $row) {
      $this->addRow($row);
    }

    return $this;
  }
}
