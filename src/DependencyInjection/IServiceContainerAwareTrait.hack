namespace Nuxed\DependencyInjection;

trait ServiceContainerAwareTrait implements IServiceContainerAware {
  <<__LateInit>> protected IServiceContainer $container;

  public function setContainer(IServiceContainer $container): void {
    $this->container = $container;
  }
}
