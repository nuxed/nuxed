namespace Nuxed\DependencyInjection;

/**
 * Describes the interface of a container that exposes methods to read its entries.
 */
interface IServiceContainer {
  /**
   * Finds services of the container by their tag and return all of them.
   *
   * @throws Exception\ContainerException Error while retrieving the services.
   */
  public function tagged<<<__Enforceable>> reify T>(
    classname<T> $tag,
  ): Container<T>;

  /**
  * Finds a service of the container by its type and returns it.
  *
  * @throws Exception\NotFoundException  Service is not managed by the container.
  * @throws Exception\ContainerException Error while retrieving the service.
  */
  public function get<<<__Enforceable>> reify T>(classname<T> $service): T;

  /**
   * Returns true if the container contains the service.
   * Returns false otherwise.
   *
   * `has<T>($service)` returning true does not mean that `get<T>($service)` will not throw an exception.
   * It does however mean that `get($id)` will not throw a `Exception\NotFoundException`.
   */
  public function has<<<__Enforceable>> reify T>(classname<T> $service): bool;
}
