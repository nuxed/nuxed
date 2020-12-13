namespace Nuxed\Http\Emitter\Exception;

/**
 * Every HTTP emitter related exception MUST implement this interface.
 */
<<__Sealed(RuntimeException::class)>>
interface IException {
  require extends \Exception;
}
