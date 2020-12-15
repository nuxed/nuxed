namespace Nuxed\Kernel\DependencyInjection\ServiceProvider\Log;

use namespace Nuxed\{Configuration, DependencyInjection, Log};
use namespace Nuxed\Kernel\DependencyInjection\Factory;

final class LogServiceProvider implements DependencyInjection\IServiceProvider {
  const type THandlerConfig = shape(
    'type' => string,
    ?'path' => string, // types: file
    ?'level' => Log\LogLevel, // defaults to Log\LogLevel::DEBUG, types: all
    ?'bubble' => bool, // defaults to true, types: all
  );

  const type TConfig = shape(
    ?'max_message_length' => ?int,
    ?'format' => string,
    ?'date_format' => string,
    ?'allow_inline_line_breaks' => bool,
    ?'ignore_empty_context' => bool,
    'handlers' => vec<this::THandlerConfig>,
  );

  public function register(
    DependencyInjection\ContainerBuilder $builder,
    Configuration\IConfiguration $_configurations,
  ): void {
    $builder->register(new Formatter\FormatterServiceProvider());
    $builder->register(new Handler\HandlerServiceProvider());
    $builder->register(new Processor\ProcessorServiceProvider());

    $builder->add<Log\Logger>(
      Log\Logger::class,
      new Factory\Log\LoggerFactory(),
    );

    $builder->add<Log\NullLogger>(
      Log\NullLogger::class,
      new Factory\Log\NullLoggerFactory(),
    );

    $builder->add<Log\ILogger>(
      Log\ILogger::class,
      DependencyInjection\alias<Log\ILogger, Log\Logger>(Log\Logger::class),
    );
  }
}
