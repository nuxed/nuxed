/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Process\Exception;

<<__Sealed(FailedExecutionException::class, PossibleAttackException::class)>>
class RuntimeException extends \RuntimeException implements IException {
}
