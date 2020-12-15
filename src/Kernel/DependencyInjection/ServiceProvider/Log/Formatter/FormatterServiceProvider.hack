namespace Nuxed\Kernel\DependencyInjection\ServiceProvider\Log\Formatter;

use namespace Nuxed\{Configuration, DependencyInjection, Log};
use namespace Nuxed\Kernel\DependencyInjection\{Factory, ServiceProvider};
use namespace Nuxed\Log\Formatter;

final class FormatterServiceProvider
  implements DependencyInjection\IServiceProvider {
  public function register(
    DependencyInjection\ContainerBuilder $builder,
    Configuration\IConfiguration $configurations,
  ): void {
    $configuration = $configurations->get<
      ServiceProvider\Log\LogServiceProvider::TConfig,
    >('log');

    $format = Shapes::idx(
      $configuration,
      'format',
      Formatter\LineFormatter::SIMPLE_FORMAT,
    );

    $date = Shapes::idx(
      $configuration,
      'date_format',
      Formatter\LineFormatter::SIMPLE_DATE,
    );

    $allow_inline_line_breaks = Shapes::idx(
      $configuration,
      'allow_inline_line_breaks',
      false,
    );

    $ignore_empty_context = Shapes::idx(
      $configuration,
      'ignore_empty_context',
      true,
    );

    $builder->add<Log\Formatter\LineFormatter>(
      Log\Formatter\LineFormatter::class,
      new Factory\Log\Handler\LineFormatterFactory(
        $format,
        $date,
        $allow_inline_line_breaks,
        $ignore_empty_context,
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
}
