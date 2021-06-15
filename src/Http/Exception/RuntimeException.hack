namespace Nuxed\Http\Exception;

<<__Sealed(
  UploadedFileErrorException::class,
  UploadedFileAlreadyMovedException::class,
  ServerException::class,
  NetworkException::class,
)>>
class RuntimeException extends \RuntimeException implements IException {
}
