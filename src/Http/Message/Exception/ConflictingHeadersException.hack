namespace Nuxed\Http\Message\Exception;


/**
 * The HTTP request contains headers with conflicting information.
 */
final class ConflictingHeadersException
  extends \UnexpectedValueException
  implements IException {
}
