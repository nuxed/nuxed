namespace Nuxed\Translation\Loader;

use namespace HH;
use namespace Nuxed\{Filesystem, Translation};
use namespace HH\Lib\Str;
use namespace Nuxed\Translation\{Exception, Reader};
use namespace Facebook\TypeSpec;

abstract class FileLoader implements ILoader {
  public async function load(
    string $resource,
    string $locale,
    string $domain = 'messages',
  ): Awaitable<Translation\MessageCatalogue> {
    $resource = Filesystem\Path::create($resource);
    if (!$resource->exists()) {
      throw new Exception\NotFoundResourceException(
        Str\format('File (%s) not found.', $resource->toString()),
      );
    }

    if (!$resource->isFile()) {
      throw new Exception\InvalidResourceException(Str\format(
        'Path (%s) points to a folder, please use %s instead.',
        $resource->toString(),
        Reader\ITranslationReader::class,
      ));
    }

    $resource = await $this->loadResource($resource->toString());
    $catalogue = new Translation\MessageCatalogue($locale);
    $catalogue->add($this->flatten($resource), $domain);

    return $catalogue;
  }

  /**
   * @return tree<arraykey, string>
   */
  abstract protected function loadResource(
    string $resource,
  ): Awaitable<KeyedContainer<string, mixed>>;

  private function flatten(
    KeyedContainer<string, mixed> $tree,
  ): KeyedContainer<string, string> {
    $result = dict[];
    foreach ($tree as $key => $value) {
      if ($value is arraykey || $value is num) {
        $result[$key] = $value is num
          ? Str\format_number($value, 2)
          : (string)$value;
      } else {
        $value = TypeSpec\dict(TypeSpec\string(), TypeSpec\mixed())
          ->coerceType($value);
        foreach ($this->flatten($value) as $k => $v) {
          $result[$key.'.'.$k] = $v;
        }
      }
    }

    return $result;
  }
}
