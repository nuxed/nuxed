namespace Nuxed\Kernel\DependencyInjection\Processor\EventDispatcher\ListenerProvider;

use namespace Nuxed\DependencyInjection;
use namespace Nuxed\EventDispatcher\ListenerProvider;

final class ListenerProviderProcessor
  implements DependencyInjection\Processor\IProcessor {

  public function process<<<__Enforceable>> reify T>(
    DependencyInjection\ServiceDefinition<T> $definition,
  ): DependencyInjection\ServiceDefinition<T> {
    if (
      \is_a(
        $definition->getType(),
        ListenerProvider\IListenerProvider::class,
        true,
      )
    ) {
      return $definition->withTag<ListenerProvider\IListenerProvider>(
        ListenerProvider\IListenerProvider::class,
      );
    }

    return $definition;
  }
}
