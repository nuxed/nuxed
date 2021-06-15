namespace Nuxed\Http\Exception;

use namespace HH\Lib\{C, Str, Vec};
use namespace Nuxed\Http\Message;

final class NotFoundException extends ServerException {
  public function __construct() {
    parent::__construct(Message\StatusCode::NOT_FOUND);
  }
}
