namespace Nuxed\Environment\Exception;

final class RuntimeException extends \RuntimeException implements IException {
  const int MissingModeVariable = 1;
  const int InvalidModeValue = 2;

  <<__Pure>>
  public function __construct(string $message, int $code) {
    parent::__construct($message, $code);
  }
}
