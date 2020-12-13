namespace Nuxed\DependencyInjection;

interface IServiceContainerAware {
  /**
   * Sets the container.
   */
  public function setContainer(IServiceContainer $container): void;
}
