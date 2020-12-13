namespace Nuxed\Console\Output;

interface IConsoleOutput extends IOutput {
  /**
   * Return the standard error output.
   */
  public function getErrorOutput(): IOutput;
}
