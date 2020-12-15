namespace Nuxed\Kernel\DependencyInjection\Factory\Log\Handler;

use namespace Nuxed\DependencyInjection\Factory;
use namespace Nuxed\{DependencyInjection, Filesystem, Log};
use namespace Nuxed\Log\{Formatter, Handler};

final class FileHandlerFactory
  implements Factory\IFactory<Handler\FileHandler> {

  public function __construct(
    private string $file,
    private Log\LogLevel $level,
    private bool $bubble,
  ) {}

  public function create(
    DependencyInjection\IServiceContainer $container,
  ): Handler\FileHandler {
    return new Handler\FileHandler(
      new Filesystem\File($this->file),
      $container->get<Formatter\IFormatter>(Formatter\IFormatter::class),
      $this->level,
      $this->bubble,
    );
  }
}
