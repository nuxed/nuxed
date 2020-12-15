namespace Nuxed\Kernel\DependencyInjection\Factory\Log;

use namespace Nuxed\DependencyInjection\Factory;
use namespace Nuxed\{DependencyInjection, Log};

final class NullLoggerFactory implements Factory\IFactory<Log\NullLogger> {
  public function create(
    DependencyInjection\IServiceContainer $_container,
  ): Log\NullLogger {
    return new Log\NullLogger();
  }
}
