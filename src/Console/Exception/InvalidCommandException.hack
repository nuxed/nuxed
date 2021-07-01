/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Console\Exception;

/**
 * Exception thrown when the command used in the application does not exist.
 */
final class InvalidCommandException
  extends \OutOfBoundsException
  implements Exception {

}
