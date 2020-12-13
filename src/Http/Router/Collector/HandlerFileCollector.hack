namespace Nuxed\Http\Router\Collector;

use namespace HH\Lib\{C, Vec};
use namespace Facebook\DefinitionFinder;
use namespace Nuxed\Http\Router;
use namespace Nuxed\Http\Server\Handler;

final class HandlerFileCollector implements ICollector {
  public function __construct(private string $file) {
  }

  public async function collect(): Awaitable<Router\RouteCollection> {
    $handlers = vec[];
    $parser = await DefinitionFinder\FileParser::fromFileAsync($this->file);

    $classes = $parser->getClasses();
    foreach ($classes as $class) {
      $handler = $this->getHandler($class);
      if ($handler is nonnull) {
        $handlers[] = $handler;
      }
    }

    $collector = new HandlerCollector($handlers);

    return await $collector->collect();
  }

  private function getHandler(
    DefinitionFinder\ScannedClass $class,
  ): ?classname<Handler\IHandler> {
    $class = new \ReflectionClass($class->getName());
    if ($class->isAbstract() || $class->isInterface() || $class->isTrait()) {
      return null;
    }

    $interfaces = $class->getInterfaceNames();
    $parent = $class->getParentClass();
    while ($parent is \ReflectionClass) {
      $interfaces = Vec\concat($interfaces, $parent->getInterfaceNames());
      $parent = $class->getParentClass();
    }

    $isHandler = C\contains(Vec\unique($interfaces), Handler\IHandler::class);
    if (!$isHandler) {
      return null;
    }

    /* HH_IGNORE_ERROR[4110] - We are sure that `$class` represents a handler. */
    return $class->getName();
  }
}
