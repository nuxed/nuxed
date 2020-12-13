namespace Nuxed\Log\Exception;

<<__Sealed(
  InvalidArgumentException::class,
  LogicException::class,
  RuntimeException::class,
  UnexpectedValueException::class,
)>>
interface Exception {
  require extends \Exception;
}
