namespace Nuxed\Kernel\DependencyInjection\Factory\EventDispatcher\ListenerProvider;

use namespace Nuxed\DependencyInjection\Factory;
use namespace Nuxed\{DependencyInjection, EventDispatcher};

final class AttachableListenerProviderFactory
  implements Factory\IFactory<
    EventDispatcher\ListenerProvider\AttachableListenerProvider,
  > {
  public function create(
    DependencyInjection\IServiceContainer $_container,
  ): EventDispatcher\ListenerProvider\AttachableListenerProvider {
    return new EventDispatcher\ListenerProvider\AttachableListenerProvider();
  }
}
