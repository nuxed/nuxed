namespace Nuxed\Http\Exception;

final class UploadedFileAlreadyMovedException extends RuntimeException {
  public function __construct(
    string $message = 'Cannot retrieve file handle after it has already moved.',
    int $code = 0,
    ?\Exception $previous = null,
  ) {
    parent::__construct($message, $code, $previous);
  }
}
