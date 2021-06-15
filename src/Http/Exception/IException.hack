namespace Nuxed\Http\Exception;

/**
 * Every HTTP server related exception MUST implement this interface.
 */
<<__Sealed(RuntimeException::class, InvalidArgumentException::class)>>
interface IException {
  require extends \Exception;
}
