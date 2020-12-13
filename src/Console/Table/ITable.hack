namespace Nuxed\Console\Table;

/**
 * A `Table` object will construct the markup for a human readable (or otherwise
 * parsable) representation of tabular data.
 */
interface ITable {
  /**
   * Add a row of data to the end of the existing data.
   */
  public function addRow(Container<string> $row): this;

  /**
   * Build and return the markup for the `Table`.
   */
  public function render(): string;

  /**
   * Set the data of the table with A container of column name and value containers.
   * This method overwrites any existing rows in the table.
   */
  public function setData(
    Container<KeyedContainer<string, string>> $data,
  ): this;

  /**
   * Set the column names for the table.
   */
  public function setHeaders(Container<string> $headers): this;

  /**
   * Set the data for the rows in the table with A vector containing a vec
   * for each row in the table.
   */
  public function setRows(Container<Container<string>> $rows): this;
}
