namespace Nuxed\DependencyInjection\Decorator;

use namespace Nuxed\DependencyInjection;

final class CallableFactoryDecorator<<<__Enforceable>> reify T>
  implements DependencyInjection\IFactory<T> {
  public function __construct(
    private (function(DependencyInjection\IServiceContainer): T) $callable,
  ) {}

  public function create(DependencyInjection\IServiceContainer $container): T {
    return ($this->callable)($container);
  }
}
