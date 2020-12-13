namespace Nuxed\DependencyInjection;

/**
 * A factory is a service that are able to create a specifiec service
 * using dependencies retrieved from the given container.
 */
interface IFactory<T> {
  /**
   * Create service `T` using the given service container.
   */
  public function create(IServiceContainer $container): T;
}
