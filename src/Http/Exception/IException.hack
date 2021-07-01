/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http\Exception;

/**
 * Every HTTP server related exception MUST implement this interface.
 */
<<__Sealed(RuntimeException::class, InvalidArgumentException::class)>>
interface IException {
  require extends \Exception;
}
