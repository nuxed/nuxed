namespace Nuxed\DependencyInjection\Inflector;

use namespace Nuxed\DependencyInjection;

final class ServiceContainerAwareInflector
  implements IInflector<DependencyInjection\IServiceContainerAware> {

  public function inflect(
    DependencyInjection\IServiceContainerAware $service,
    DependencyInjection\IServiceContainer $container,
  ): DependencyInjection\IServiceContainerAware {
    $service->setContainer($container);

    return $service;
  }
}
