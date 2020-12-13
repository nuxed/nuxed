namespace Nuxed\Http\Server\Exception;

/**
 * Every HTTP server related exception MUST implement this interface.
 */
interface IException {
  require extends \Exception;
}
