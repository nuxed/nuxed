/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Console\Exception;

use namespace Nuxed\Console\Command;

/**
 * Exception thrown when an invalid command name is provided to the application.
 */
final class CommandNotFoundException
  extends \RuntimeException
  implements Exception {

  <<__Override>>
  public function getCode()[]: int {
    return Command\ExitCode::COMMAND_NOT_FOUND;
  }
}
