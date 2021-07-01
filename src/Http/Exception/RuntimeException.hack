/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http\Exception;

<<__Sealed(
  UploadedFileErrorException::class,
  UploadedFileAlreadyMovedException::class,
  ServerException::class,
  NetworkException::class,
)>>
class RuntimeException extends \RuntimeException implements IException {
}
