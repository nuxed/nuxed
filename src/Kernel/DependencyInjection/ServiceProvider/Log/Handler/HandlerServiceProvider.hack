namespace Nuxed\Kernel\DependencyInjection\ServiceProvider\Log\Handler;

use namespace Nuxed\{Configuration, DependencyInjection, Log};
use namespace Nuxed\Kernel\DependencyInjection\{Factory, ServiceProvider};

final class HandlerServiceProvider
  implements DependencyInjection\IServiceProvider {

  public function register(
    DependencyInjection\ContainerBuilder $builder,
    Configuration\IConfiguration $configurations,
  ): void {
    $config = $configurations->get<
      ServiceProvider\Log\LogServiceProvider::TConfig,
    >('log');
    foreach ($config['handlers'] as $handler) {
      $this->addHandler($builder, $handler);
    }
  }

  private function addHandler(
    DependencyInjection\ContainerBuilder $builder,
    ServiceProvider\Log\LogServiceProvider::THandlerConfig $configuration,
  ): void {
    $level = Shapes::idx($configuration, 'level', Log\LogLevel::DEBUG);
    $bubble = Shapes::idx($configuration, 'bubble', true);

    if ($configuration['type'] === 'file') {
      $file = Shapes::at($configuration, 'path');

      $builder->add<Log\Handler\FileHandler>(
        Log\Handler\FileHandler::class,
        new Factory\Log\Handler\FileHandlerFactory($file, $level, $bubble),
      );

      $builder->tag<Log\Handler\IHandler, Log\Handler\FileHandler>(
        Log\Handler\IHandler::class,
        Log\Handler\FileHandler::class,
      );

      return;
    }

    invariant_violation(
      'Invalid handler type "%s", supported types: "%s".',
      $configuration['type'],
      'file',
    );
  }
}
