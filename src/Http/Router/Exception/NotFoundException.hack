namespace Nuxed\Http\Router\Exception;

use namespace Nuxed\Http;

/**
 * Exception thrown when no route is matched.
 */
final class NotFoundException extends RuntimeException {
  public function __construct() {
    parent::__construct('Route not found.', Http\Message\StatusCode::NOT_FOUND);
  }
}
