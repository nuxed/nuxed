namespace Nuxed\DependencyInjection\Inflector;

use namespace Nuxed\DependencyInjection;

interface IInflector<T> {
  public function inflect(
    T $service,
    DependencyInjection\IServiceContainer $container,
  ): T;
}
