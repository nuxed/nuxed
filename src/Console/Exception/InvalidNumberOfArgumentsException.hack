namespace Nuxed\Console\Exception;

/**
 * Exception thrown when parameters are passed in the input that do not belong
 * to registered input definitions.
 */
final class InvalidNumberOfArgumentsException
  extends \InvalidArgumentException
  implements Exception {

}
