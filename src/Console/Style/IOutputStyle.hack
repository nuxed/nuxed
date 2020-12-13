namespace Nuxed\Console\Style;

use namespace Nuxed\Console\Output;

interface IOutputStyle extends IStyle, Output\IOutput {
  /**
   * Return the underlying output object.
   */
  public function getOutput(): Output\IOutput;
}
