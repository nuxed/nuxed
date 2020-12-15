namespace Nuxed\DependencyInjection\Processor;

use namespace Nuxed\DependencyInjection;

interface IProcessor {
  /**
   * Process the given service definition and return the
   * modified service definition.
   */
  public function process<<<__Enforceable>> reify T>(
    DependencyInjection\ServiceDefinition<T> $definition,
  ): DependencyInjection\ServiceDefinition<T>;
}
