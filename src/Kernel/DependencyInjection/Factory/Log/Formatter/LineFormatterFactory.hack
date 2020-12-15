namespace Nuxed\Kernel\DependencyInjection\Factory\Log\Handler;

use namespace Nuxed\DependencyInjection\Factory;
use namespace Nuxed\DependencyInjection;
use namespace Nuxed\Log\Formatter;

final class LineFormatterFactory
  implements Factory\IFactory<Formatter\LineFormatter> {

  public function __construct(
    private ?string $format,
    private ?string $dateFormat,
    private bool $allowInlineLineBreaks,
    private bool $ignoreEmptyContext,
  ) {}

  public function create(
    DependencyInjection\IServiceContainer $_container,
  ): Formatter\LineFormatter {
    return new Formatter\LineFormatter(
      $this->format,
      $this->dateFormat,
      $this->allowInlineLineBreaks,
      $this->ignoreEmptyContext,
    );
  }
}
