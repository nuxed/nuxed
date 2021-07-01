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
 * Exception thrown when a value is required and not present. This can be the
 * case with options or arguments.
 */
final class MissingValueException
  extends \RuntimeException
  implements Exception {

}
