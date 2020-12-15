namespace Nuxed\Kernel\DependencyInjection\Factory\Stopwatch;

use namespace Nuxed\DependencyInjection\Factory;
use namespace Nuxed\{DependencyInjection, Stopwatch};

final class StopwatchFactory implements Factory\IFactory<Stopwatch\Stopwatch> {
  public function create(
    DependencyInjection\IServiceContainer $_container,
  ): Stopwatch\Stopwatch {
    return new Stopwatch\Stopwatch();
  }
}
