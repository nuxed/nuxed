namespace Nuxed\DependencyInjection;

use namespace Nuxed\Configuration;

interface IServiceProvider {
  /**
   * Register services in the container using the provided configuration.
   */
  public function register(
    ContainerBuilder $builder,
    Configuration\IConfiguration $configuration,
  ): void;
}
