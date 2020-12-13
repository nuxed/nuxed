namespace Nuxed\DependencyInjection\Decorator;

use namespace Nuxed\DependencyInjection;

final class CallableInflectorDecorator<<<__Enforceable>> reify T>
  implements DependencyInjection\IInflector<T> {
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
