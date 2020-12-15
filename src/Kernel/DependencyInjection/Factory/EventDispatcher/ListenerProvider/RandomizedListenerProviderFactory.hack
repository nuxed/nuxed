namespace Nuxed\Kernel\DependencyInjection\Factory\EventDispatcher\ListenerProvider;

use namespace Nuxed\DependencyInjection\Factory;
use namespace Nuxed\{DependencyInjection, EventDispatcher};

final class RandomizedListenerProviderFactory
  implements Factory\IFactory<
    EventDispatcher\ListenerProvider\RandomizedListenerProvider,
  > {
  public function create(
    DependencyInjection\IServiceContainer $_container,
  ): EventDispatcher\ListenerProvider\RandomizedListenerProvider {
    return new EventDispatcher\ListenerProvider\RandomizedListenerProvider();
  }
}
