/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



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
