namespace Nuxed\DependencyInjection\Factory\Decorator;

use namespace Nuxed\DependencyInjection;
use namespace Nuxed\DependencyInjection\Factory;

final class CallableFactoryDecorator<<<__Enforceable>> reify T>
  implements Factory\IFactory<T> {
  public function __construct(
    private (function(DependencyInjection\IServiceContainer): T) $callable,
  ) {}

  public function create(DependencyInjection\IServiceContainer $container): T {
    return ($this->callable)($container);
  }
}
