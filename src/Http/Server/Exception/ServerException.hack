namespace Nuxed\Http\Server\Exception;

use namespace Nuxed\Http\Message;
use namespace HH\Lib\IO;

final class ServerException extends RuntimeException {
  public function __construct(
    protected int $status = Message\StatusCode::INTERNAL_SERVER_ERROR,
    protected KeyedContainer<string, Container<string>> $headers = dict[],
    protected ?IO\SeekableReadWriteHandle $body = null,
  ) {
    parent::__construct(
      Message\Response::$phrases[$status] ?? Message\Response::$phrases[500],
    );
  }

  public function getStatusCode(): int {
    return $this->status;
  }

  public function getHeaders(): KeyedContainer<string, Container<string>> {
    return $this->headers;
  }

  public function getBody(): ?IO\SeekableReadWriteHandle {
    return $this->body;
  }
}
