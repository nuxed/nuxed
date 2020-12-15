namespace Nuxed\Kernel\DependencyInjection\Processor\Console;

use namespace Nuxed\{Console, DependencyInjection};

final class CommandProcessor
  implements DependencyInjection\Processor\IProcessor {

  public function process<<<__Enforceable>> reify T>(
    DependencyInjection\ServiceDefinition<T> $definition,
  ): DependencyInjection\ServiceDefinition<T> {
    if (\is_a($definition->getType(), Console\Command\Command::class, true)) {
      return $definition->withTag<Console\Command\Command>(
        Console\Command\Command::class,
      );
    }

    return $definition;
  }
}
