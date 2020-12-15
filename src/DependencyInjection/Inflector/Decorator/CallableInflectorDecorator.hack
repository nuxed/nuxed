namespace Nuxed\DependencyInjection\Inflector\Decorator;

use namespace Nuxed\DependencyInjection;
use namespace Nuxed\DependencyInjection\Inflector;

final class CallableInflectorDecorator<<<__Enforceable>> reify T>
  implements Inflector\IInflector<T> {
  public function __construct(
    private (function(T, DependencyInjection\IServiceContainer): T) $callable,
  ) {}

  public function inflect(
    T $service,
    DependencyInjection\IServiceContainer $container,
  ): T {
    return ($this->callable)($service, $container);
  }
}
