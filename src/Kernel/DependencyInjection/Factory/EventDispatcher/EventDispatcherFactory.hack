namespace Nuxed\Kernel\DependencyInjection\Factory\EventDispatcher;

use namespace Nuxed\DependencyInjection\Factory;
use namespace Nuxed\{DependencyInjection, EventDispatcher};

final class EventDispatcherFactory
  implements Factory\IFactory<EventDispatcher\EventDispatcher> {
  public function create(
    DependencyInjection\IServiceContainer $container,
  ): EventDispatcher\EventDispatcher {
    $aggregate =
      new EventDispatcher\ListenerProvider\ListenerProviderAggregate();

    foreach (
      $container->tagged<EventDispatcher\ListenerProvider\IListenerProvider>(
        EventDispatcher\ListenerProvider\IListenerProvider::class,
      ) as $provider
    ) {
      $aggregate->attach($provider);
    }

    return new EventDispatcher\EventDispatcher($aggregate);
  }
}
