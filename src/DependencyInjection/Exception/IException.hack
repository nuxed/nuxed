namespace Nuxed\DependencyInjection\Exception;

/**
 * Base interface representing a generic exception in a container.
 */
<<__Sealed(ContainerException::class, NotFoundException::class)>>
interface IException {
  require extends \Exception;
}
