namespace Nuxed\Translation\Reader;

use namespace HH\Asio;
use namespace HH\Lib\Str;
use namespace Nuxed\{Filesystem, Translation};
use namespace Nuxed\Translation\Loader;
use namespace Facebook\TypeAssert;

/**
 * TranslationReader reads translation messages from translation files.
 */
final class TranslationReader implements ITranslationReader {
  /**
   * Loaders used for import.
   */
  private dict<string, Loader\ILoader> $loaders = dict[];

  /**
   * Adds a loader to the translation reader.
   */
  public function addLoader<T>(string $format, Loader\ILoader $loader): this {
    $this->loaders[$format] = $loader;
    return $this;
  }

  /**
   * Reads translation messages from a directory to the catalogue.
   */
  public async function read(
    string $directory,
    Translation\MessageCatalogue $catalogue,
  ): Awaitable<void> {
    $files = await Asio\wrap(async {
      $folder = Filesystem\Node::load($directory) as Filesystem\Folder;
      return await $folder->files(false, true);
    });

    if ($files->isFailed()) {
      return;
    }

    $files = $files->getResult();
    $lastOperation = async {
    };

    foreach ($this->loaders as $format => $loader) {
      $extension = Str\format('.%s.%s', $catalogue->getLocale(), $format);
      foreach ($files as $file) {
        $basename = $file->path()->basename();
        if (Str\ends_with($basename, $extension)) {
          $lastOperation = async {
            await $lastOperation;
            $domain = Str\strip_suffix($basename, $extension);
            $resource = TypeAssert\matches_type_structure(
              $loader->getFormat(),
              $file->path()->toString(),
            );

            $catalogue->addCatalogue(
              await $loader->load($resource, $catalogue->getLocale(), $domain),
            );
          };
        }
      }
    }

    await $lastOperation;
  }
}
