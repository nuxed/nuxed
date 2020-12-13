namespace Nuxed\Translation\Loader;

use namespace Nuxed\Filesystem;
use namespace HH\Lib\Str;
use namespace Facebook\TypeSpec;
use namespace Nuxed\Translation\Exception;

final class IniFileLoader extends FileLoader {
  <<__Override>>
  public async function loadResource(
    string $resource,
  ): Awaitable<KeyedContainer<string, mixed>> {
    $file = Filesystem\Node::load($resource) as Filesystem\File;

    try {
      $contents = await $file->read();
      $messages = \parse_ini_string($contents, true);

      if (false === $messages) {
        throw new Exception\InvalidResourceException(
          Str\format('Error parsing ini file (%s).', $resource),
        );
      }

      return TypeSpec\dict(TypeSpec\string(), TypeSpec\mixed())
        ->coerceType($messages ?? dict[]);
    } catch (Filesystem\Exception\IException $e) {
      throw new Exception\InvalidResourceException(
        Str\format('Unable to load file content (%s).', $resource),
        $e->getCode(),
        $e,
      );
    }
  }
}
