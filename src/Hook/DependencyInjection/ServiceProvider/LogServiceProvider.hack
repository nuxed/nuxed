namespace Nuxed\Hook\DependencyInjection\ServiceProvider;

use namespace Nuxed\{Configuration, DependencyInjection, Filesystem, Log};

final class LogServiceProvider implements DependencyInjection\IServiceProvider {
  const type THandlerConfig = shape(
    'type' => string,
    ?'path' => string, // types: file
    ?'level' => Log\LogLevel, // defaults to Log\LogLevel::DEBUG, types: all
    ?'bubble' => bool, // defaults to true, types: all
  );

  const type TConfig = shape(
    ?'enabled' => bool,
    ?'max_message_length' => ?int,
    ?'format' => string,
    ?'date_format' => string,
    ?'allow_inline_line_breaks' => bool,
    ?'ignore_empty_context' => bool,
    'handlers' => vec<this::THandlerConfig>,
  );

  public function register(
    DependencyInjection\ContainerBuilder $builder,
    Configuration\IConfiguration $configurations,
  ): void {
    $config = $configurations->get<this::TConfig>('log');
    foreach ($config['handlers'] as $handler) {
      $this->addHandler($builder, $handler);
    }

    $this->addForamtters($builder, $config);
    $this->addProcessors($builder, $config);

    $builder->add<Log\Logger>(
      Log\Logger::class,
      DependencyInjection\factory<Log\Logger>(
        (DependencyInjection\IServiceContainer $container): Log\Logger ==> {
          $handlers = $container->tagged<Log\Handler\IHandler>(
            Log\Handler\IHandler::class,
          );

          $processors = $container->tagged<Log\Processor\IProcessor>(
            Log\Processor\IProcessor::class,
          );

          return new Log\Logger($handlers, $processors);
        },
      ),
    );

    $builder->add<Log\NullLogger>(
      Log\NullLogger::class,
      DependencyInjection\factory<Log\NullLogger>(
        (DependencyInjection\IServiceContainer $container): Log\NullLogger ==>
          new Log\NullLogger(),
      ),
    );

    if (Shapes::idx($config, 'enabled', true)) {
      $builder->add<Log\ILogger>(
        Log\ILogger::class,
        DependencyInjection\alias<Log\ILogger, Log\Logger>(Log\Logger::class),
      );
    } else {
      $builder->add<Log\ILogger>(
        Log\ILogger::class,
        DependencyInjection\alias<Log\ILogger, Log\NullLogger>(
          Log\NullLogger::class,
        ),
      );
    }
  }


  private function addHandler(
    DependencyInjection\ContainerBuilder $builder,
    this::THandlerConfig $configuration,
  ): void {
    $level = Shapes::idx($configuration, 'level', Log\LogLevel::DEBUG);
    $bubble = Shapes::idx($configuration, 'bubble', true);

    if ($configuration['type'] === 'file') {
      $file = Shapes::at($configuration, 'path');
      $builder->add<Log\Handler\FileHandler>(
        Log\Handler\FileHandler::class,
        DependencyInjection\factory<Log\Handler\FileHandler>(
          (
            DependencyInjection\IServiceContainer $container,
          ): Log\Handler\FileHandler ==> {
            return new Log\Handler\FileHandler(
              new Filesystem\File($file),
              $container->get<Log\Formatter\IFormatter>(
                Log\Formatter\IFormatter::class,
              ),
              $level,
              $bubble,
            );
          },
        ),
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

  private function addForamtters(
    DependencyInjection\ContainerBuilder $builder,
    this::TConfig $configuration,
  ): void {
    $builder->add<Log\Formatter\LineFormatter>(
      Log\Formatter\LineFormatter::class,
      DependencyInjection\factory<Log\Formatter\LineFormatter>(
        ($container): Log\Formatter\LineFormatter ==>
          new Log\Formatter\LineFormatter(
            $configuration['format'] ??
              Log\Formatter\LineFormatter::SIMPLE_FORMAT,
            $configuration['date_format'] ??
              Log\Formatter\LineFormatter::SIMPLE_DATE,
            $configuration['allow_inline_line_breaks'] ?? false,
            $configuration['ignore_empty_context'] ?? true,
          ),
      ),
    );

    $builder->add<Log\Formatter\IFormatter>(
      Log\Formatter\IFormatter::class,
      DependencyInjection\alias<
        Log\Formatter\IFormatter,
        Log\Formatter\LineFormatter,
      >(Log\Formatter\LineFormatter::class),
    );
  }

  private function addProcessors(
    DependencyInjection\ContainerBuilder $builder,
    this::TConfig $configuration,
  ): void {
    $builder->add<Log\Processor\ContextProcessor>(
      Log\Processor\ContextProcessor::class,
      DependencyInjection\factory<Log\Processor\ContextProcessor>(
        ($container): Log\Processor\ContextProcessor ==>
          new Log\Processor\ContextProcessor(),
      ),
    );

    $builder->tag<Log\Processor\IProcessor, Log\Processor\ContextProcessor>(
      Log\Processor\IProcessor::class,
      Log\Processor\ContextProcessor::class,
    );

    $message_length = Shapes::idx($configuration, 'max_message_length', 1024);
    if ($message_length is nonnull) {
      $builder->add<Log\Processor\MessageLengthProcessor>(
        Log\Processor\MessageLengthProcessor::class,
        DependencyInjection\factory<Log\Processor\MessageLengthProcessor>(
          ($container): Log\Processor\MessageLengthProcessor ==>
            new Log\Processor\MessageLengthProcessor(),
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
