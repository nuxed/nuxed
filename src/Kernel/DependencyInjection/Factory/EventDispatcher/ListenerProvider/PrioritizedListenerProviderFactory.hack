namespace Nuxed\Kernel\DependencyInjection\Factory\EventDispatcher\ListenerProvider;

use namespace Nuxed\DependencyInjection\Factory;
use namespace Nuxed\{DependencyInjection, EventDispatcher};

final class PrioritizedListenerProviderFactory
  implements Factory\IFactory<
    EventDispatcher\ListenerProvider\PrioritizedListenerProvider,
  > {
  public function create(
    DependencyInjection\IServiceContainer $_container,
  ): EventDispatcher\ListenerProvider\PrioritizedListenerProvider {
    return new EventDispatcher\ListenerProvider\PrioritizedListenerProvider();
  }
}
