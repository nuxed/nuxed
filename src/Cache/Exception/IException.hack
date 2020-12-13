namespace Nuxed\Cache\Exception;

<<__Sealed(
  RuntimeException::class,
  InvalidArgumentException::class,
  LogicException::class,
)>>
interface IException {
  require extends \Exception;
}
