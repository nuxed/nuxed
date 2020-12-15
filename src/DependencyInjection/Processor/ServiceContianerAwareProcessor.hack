namespace Nuxed\DependencyInjection\Processor;

use namespace Nuxed\DependencyInjection;
use namespace Nuxed\DependencyInjection\Inflector;

final class ServiceContainerAwareProcessor implements IProcessor {
  /**
   * Process the given service definition and return the
   * modified service definition.
   */
  public function process<<<__Enforceable>> reify T>(
    DependencyInjection\ServiceDefinition<T> $definition,
  ): DependencyInjection\ServiceDefinition<T> {
    if (
      \is_a(
        $definition->getType(), // classname<T>
        DependencyInjection\IServiceContainerAware::class,
        true,
      )
    ) {
      $definition->withInflector(
        /* HH_IGNORE_ERROR[4110] - hack can't understand this, but it is valid. */
        new Inflector\ServiceContainerAwareInflector(),
      );
    }

    return $definition;
  }
}
