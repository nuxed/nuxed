namespace Nuxed\Kernel\DependencyInjection\ServiceProvider\EventDispatcher;

use namespace Nuxed\{Configuration, DependencyInjection, EventDispatcher};
use namespace Nuxed\Kernel\DependencyInjection\Factory;

final class EventDispatcherServiceProvider
  implements DependencyInjection\IServiceProvider {
  public function register(
    DependencyInjection\ContainerBuilder $builder,
    Configuration\IConfiguration $_configurations,
  ): void {
    $builder->register(new ListenerProvider\ListenerProviderServiceProvider());

    $builder->add<EventDispatcher\EventDispatcher>(
      EventDispatcher\EventDispatcher::class,
      new Factory\EventDispatcher\EventDispatcherFactory(),
    );
  }
}
