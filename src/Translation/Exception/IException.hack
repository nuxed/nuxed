namespace Nuxed\Translation\Exception;

/**
 * Every translation related exception MUST implement this interface.
 */
<<__Sealed(
  InvalidArgumentException::class,
  LogicException::class,
  RuntimeException::class,
)>>
interface IException {
  require extends \Exception;
}
