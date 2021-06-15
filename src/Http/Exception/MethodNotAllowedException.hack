namespace Nuxed\Http\Exception;

use namespace HH\Lib\{C, Str, Vec};
use namespace Nuxed\Http\Message;

final class MethodNotAllowedException extends ServerException {
  public function __construct(protected keyset<Message\HttpMethod> $allowed) {

    parent::__construct(Message\StatusCode::METHOD_NOT_ALLOWED, dict[
      'Allow' => vec($allowed),
    ]);
  }

  public function getAllowedMethods()[]: keyset<Message\HttpMethod> {
    return $this->allowed;
  }
}
