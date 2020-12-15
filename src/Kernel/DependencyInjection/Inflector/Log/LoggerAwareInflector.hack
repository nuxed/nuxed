namespace Nuxed\Kernel\DependencyInjection\Inflector\Log;

use namespace Nuxed\{DependencyInjection, Log};

final class LoggerAwareInflector
  implements DependencyInjection\Inflector\IInflector<Log\ILoggerAware> {

  public function inflect(
    Log\ILoggerAware $service,
    DependencyInjection\IServiceContainer $container,
  ): Log\ILoggerAware {
    $logger = $container->get<Log\ILogger>(Log\ILogger::class);

    $service->setLogger($logger);

    return $service;
  }
}
