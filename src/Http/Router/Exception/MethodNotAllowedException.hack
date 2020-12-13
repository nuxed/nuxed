namespace Nuxed\Http\Router\Exception;

use namespace HH\Lib\{C, Str};
use namespace Nuxed\Http;

final class MethodNotAllowedException extends RuntimeException {
  public function __construct(
    protected string $method,
    protected vec<string> $allowed,
  ) {
    $message = Str\format(
      'Method "%s" doesn\'t satisfy the current route, only "%s" method%s allowed.',
      $method,
      Str\join($allowed, '|'),
      C\count($allowed) > 1 ? 's are' : ' is',
    );

    parent::__construct($message, Http\Message\StatusCode::METHOD_NOT_ALLOWED);
  }

  public function getAllowedMethods(): vec<string> {
    return $this->allowed;
  }
}
