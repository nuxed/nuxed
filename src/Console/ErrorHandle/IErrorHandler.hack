namespace Nuxed\Console\ErrorHandler;

use namespace Nuxed\Console\{Command, Input, Output};

interface IErrorHandler {
  /**
   * Handle the given error and return the propoer exit code.
   */
  public function handle(
    Input\IInput $input,
    Output\IOutput $output,
    \Throwable $exception,
    ?Command\Command $command = null,
  ): Awaitable<int>;
}
