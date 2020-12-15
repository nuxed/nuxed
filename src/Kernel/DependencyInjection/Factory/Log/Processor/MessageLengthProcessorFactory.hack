namespace Nuxed\Kernel\DependencyInjection\Factory\Log\Processor;

use namespace Nuxed\DependencyInjection\Factory;
use namespace Nuxed\DependencyInjection;
use namespace Nuxed\Log\Processor;

final class MessageLengthProcessorFactory
  implements Factory\IFactory<Processor\MessageLengthProcessor> {

  public function __construct(private int $maxLength) {}

  public function create(
    DependencyInjection\IServiceContainer $_container,
  ): Processor\MessageLengthProcessor {
    return new Processor\MessageLengthProcessor($this->maxLength);
  }
}
