namespace Nuxed\Kernel\DependencyInjection\Processor\Log;

use namespace Nuxed\{DependencyInjection, Log};
use namespace Nuxed\Kernel\DependencyInjection\Inflector;

final class LoggerAwareInflector
  implements DependencyInjection\Processor\IProcessor {

  public function process<<<__Enforceable>> reify T>(
    DependencyInjection\ServiceDefinition<T> $definition,
  ): DependencyInjection\ServiceDefinition<T> {
    if (\is_a($definition->getType(), Log\ILoggerAware::class, true)) {
      /* HH_IGNORE_ERROR[4110] - hack can't understand this, but it is valid. */
      return $definition->withInflector(new Inflector\Log\LoggerAwareInflector());
    }

    return $definition;
  }
}
