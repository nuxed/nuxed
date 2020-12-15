namespace Nuxed\Kernel\DependencyInjection\ServiceProvider\Stopwatch;

use namespace Nuxed\{Configuration, DependencyInjection, Stopwatch};
use namespace Nuxed\Kernel\DependencyInjection\Factory;

final class StopwatchServiceProvider
  implements DependencyInjection\IServiceProvider {
  public function register(
    DependencyInjection\ContainerBuilder $builder,
    Configuration\IConfiguration $_configurations,
  ): void {
    $builder->add<Stopwatch\Stopwatch>(
      Stopwatch\Stopwatch::class,
      new Factory\Stopwatch\StopwatchFactory(),
    );
  }
}
