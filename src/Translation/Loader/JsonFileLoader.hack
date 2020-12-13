namespace Nuxed\Translation\Loader;

use namespace HH\Lib\Str;
use namespace Nuxed\{Filesystem, Json};
use namespace Facebook\TypeSpec;
use namespace Nuxed\Translation\Exception;

final class JsonFileLoader extends FileLoader {
  <<__Override>>
  public async function loadResource(
    string $resource,
  ): Awaitable<KeyedContainer<string, mixed>> {
    $file = Filesystem\Node::load($resource) as Filesystem\File;

    try {
      $contents = await $file->read();
      $messages = Json\decode($contents);
      return TypeSpec\dict(TypeSpec\string(), TypeSpec\mixed())
        ->coerceType($messages ?? dict[]);
    } catch (Filesystem\Exception\IException $e) {
      throw new Exception\InvalidResourceException(
        Str\format('Unable to load file content (%s).', $resource),
        $e->getCode(),
        $e,
      );
    } catch (Json\Exception\IException $e) {
      throw new Exception\InvalidResourceException(
        Str\format('Error parsing json file (%s).', $resource),
        $e->getCode(),
        $e,
      );
    }
  }
}
