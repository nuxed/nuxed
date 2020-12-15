namespace Nuxed\DependencyInjection\Factory;

use namespace Nuxed\DependencyInjection;

/**
 * A factory is a service that are able to create a specifiec service
 * using dependencies retrieved from the given container.
 */
interface IFactory<T> {
  /**
   * Create service `T` using the given service container.
   */
  public function create(DependencyInjection\IServiceContainer $container): T;
}
