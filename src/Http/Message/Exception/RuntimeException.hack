namespace Nuxed\Http\Message\Exception;

<<__Sealed(
  UploadedFileErrorException::class,
  UploadedFileAlreadyMovedException::class,
)>>
class RuntimeException extends \RuntimeException implements IException {
}
