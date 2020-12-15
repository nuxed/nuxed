namespace Nuxed\Kernel\DependencyInjection\ServiceProvider\EventDispatcher\ListenerProvider;

use namespace Nuxed\{Configuration, DependencyInjection, EventDispatcher};
use namespace Nuxed\Kernel\DependencyInjection\Factory;

final class ListenerProviderServiceProvider
  implements DependencyInjection\IServiceProvider {
  public function register(
    DependencyInjection\ContainerBuilder $builder,
    Configuration\IConfiguration $_configurations,
  ): void {
    $builder->add<EventDispatcher\ListenerProvider\AttachableListenerProvider>(
      EventDispatcher\ListenerProvider\AttachableListenerProvider::class,
      new Factory\EventDispatcher\ListenerProvider\AttachableListenerProviderFactory(),
    );

    $builder->tag<
      EventDispatcher\ListenerProvider\IListenerProvider,
      EventDispatcher\ListenerProvider\AttachableListenerProvider,
    >(
      EventDispatcher\ListenerProvider\IListenerProvider::class,
      EventDispatcher\ListenerProvider\AttachableListenerProvider::class,
    );

    $builder->add<EventDispatcher\ListenerProvider\RandomizedListenerProvider>(
      EventDispatcher\ListenerProvider\RandomizedListenerProvider::class,
      new Factory\EventDispatcher\ListenerProvider\RandomizedListenerProviderFactory(),
    );

    $builder->tag<
      EventDispatcher\ListenerProvider\IListenerProvider,
      EventDispatcher\ListenerProvider\RandomizedListenerProvider,
    >(
      EventDispatcher\ListenerProvider\IListenerProvider::class,
      EventDispatcher\ListenerProvider\RandomizedListenerProvider::class,
    );

    $builder->add<EventDispatcher\ListenerProvider\PrioritizedListenerProvider>(
      EventDispatcher\ListenerProvider\PrioritizedListenerProvider::class,
      new Factory\EventDispatcher\ListenerProvider\PrioritizedListenerProviderFactory(),
    );

    $builder->tag<
      EventDispatcher\ListenerProvider\IListenerProvider,
      EventDispatcher\ListenerProvider\PrioritizedListenerProvider,
    >(
      EventDispatcher\ListenerProvider\IListenerProvider::class,
      EventDispatcher\ListenerProvider\PrioritizedListenerProvider::class,
    );
  }
}
