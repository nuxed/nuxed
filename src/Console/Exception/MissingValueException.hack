namespace Nuxed\Console\Exception;

/**
 * Exception thrown when a value is required and not present. This can be the
 * case with options or arguments.
 */
final class MissingValueException
  extends \RuntimeException
  implements Exception {

}
