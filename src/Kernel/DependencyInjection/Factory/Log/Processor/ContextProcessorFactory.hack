namespace Nuxed\Kernel\DependencyInjection\Factory\Log\Processor;

use namespace Nuxed\DependencyInjection\Factory;
use namespace Nuxed\DependencyInjection;
use namespace Nuxed\Log\Processor;

final class ContextProcessorFactory
  implements Factory\IFactory<Processor\ContextProcessor> {

  public function create(
    DependencyInjection\IServiceContainer $_container,
  ): Processor\ContextProcessor {
    return new Processor\ContextProcessor();
  }
}
