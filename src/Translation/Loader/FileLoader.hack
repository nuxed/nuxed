namespace Nuxed\Translation\Loader;

use namespace HH;
use namespace Nuxed\{Filesystem, Translation};
use namespace HH\Lib\Str;
use namespace Nuxed\Translation\{Exception, Reader};

abstract class FileLoader implements ILoader {
  const type TFormat = string;

  public async function load(
    this::TFormat $resource,
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
    $loader = new TreeLoader();
    return await $loader->load($resource, $locale, $domain);
  }

  public function getFormat(): HH\TypeStructure<this::TFormat> {
    return HH\type_structure($this, 'TFormat');
  }

  /**
   * @return tree<arraykey, string>
   */
  abstract protected function loadResource(
    string $resource,
  ): Awaitable<KeyedContainer<string, mixed>>;
}
