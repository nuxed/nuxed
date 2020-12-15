namespace Nuxed\Kernel\DependencyInjection\Factory\Log;

use namespace Nuxed\DependencyInjection\Factory;
use namespace Nuxed\{DependencyInjection, Log};

final class LoggerFactory implements Factory\IFactory<Log\Logger> {
  public function create(
    DependencyInjection\IServiceContainer $container,
  ): Log\Logger {
    $handlers = $container->tagged<Log\Handler\IHandler>(
      Log\Handler\IHandler::class,
    );

    $processors = $container->tagged<Log\Processor\IProcessor>(
      Log\Processor\IProcessor::class,
    );

    return new Log\Logger($handlers, $processors);
  }
}
