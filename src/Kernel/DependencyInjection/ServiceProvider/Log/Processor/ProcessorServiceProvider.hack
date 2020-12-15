namespace Nuxed\Kernel\DependencyInjection\ServiceProvider\Log\Processor;

use namespace Nuxed\{Configuration, DependencyInjection, Log};
use namespace Nuxed\Kernel\DependencyInjection\{Factory, ServiceProvider};

final class ProcessorServiceProvider
  implements DependencyInjection\IServiceProvider {
  public function register(
    DependencyInjection\ContainerBuilder $builder,
    Configuration\IConfiguration $configurations,
  ): void {
    $configuration = $configurations->get<
      ServiceProvider\Log\LogServiceProvider::TConfig,
    >('log');

    $builder->add<Log\Processor\ContextProcessor>(
      Log\Processor\ContextProcessor::class,
      new Factory\Log\Processor\ContextProcessorFactory(),
    );

    $builder->tag<Log\Processor\IProcessor, Log\Processor\ContextProcessor>(
      Log\Processor\IProcessor::class,
      Log\Processor\ContextProcessor::class,
    );

    $message_length = Shapes::idx($configuration, 'max_message_length', 1024);
    if ($message_length is nonnull) {
      $builder->add<Log\Processor\MessageLengthProcessor>(
        Log\Processor\MessageLengthProcessor::class,
        new Factory\Log\Processor\MessageLengthProcessorFactory(
          $message_length,
        ),
      );

      $builder->tag<
        Log\Processor\IProcessor,
        Log\Processor\MessageLengthProcessor,
      >(
        Log\Processor\IProcessor::class,
        Log\Processor\MessageLengthProcessor::class,
      );
    }
  }
}
