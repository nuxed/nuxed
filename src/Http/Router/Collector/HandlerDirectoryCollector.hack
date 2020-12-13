namespace Nuxed\Http\Router\Collector;

use namespace HH\Asio;
use namespace Nuxed\Filesystem;
use namespace Nuxed\Http\Router;

final class HandlerDirectoryCollector implements ICollector {
  public function __construct(private string $directory) {
  }

  public async function collect(): Awaitable<Router\RouteCollection> {
    $folder = new Filesystem\Folder($this->directory);
    $files = await $folder->files(false, true);
    $collections = vec[];
    foreach ($files as $file) {
      $collector = new HandlerFileCollector($file->path()->toString());

      $collections[] = $collector->collect();
    }

    $mainCollection = new Router\RouteCollection();
    $collections = await Asio\v($collections);
    foreach ($collections as $collection) {
      $mainCollection->addCollection($collection);
    }

    return $mainCollection;
  }
}
