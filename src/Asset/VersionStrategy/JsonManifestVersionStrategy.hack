namespace Nuxed\Asset\VersionStrategy;

use namespace HH\Lib\Str;
use namespace Nuxed\{Filesystem, Json};
use namespace Nuxed\Asset\Exception;

/**
 * Reads the versioned path of an asset from a JSON manifest file.
 *
 * For example, the manifest file might look like this:
 *     {
 *         "main.js": "main.abc123.js",
 *         "css/styles.css": "css/styles.555abc.css"
 *     }
 *
 * You could then ask for the version of "main.js" or "css/styles.css".
 */
final class JsonManifestVersionStrategy implements IVersionStrategy {
  const type TManifest = KeyedContainer<string, string>;
  private ?KeyedContainer<string, string> $manifestData;

  public function __construct(private string $manifest) {
  }

  /**
   * With a manifest, we don't really know or care about what
   * the version is. Instead, this returns the path to the
   * versioned file.
   */
  public async function getVersion(string $path): Awaitable<string> {
    return await $this->applyVersion($path);
  }

  public async function applyVersion(string $path): Awaitable<string> {
    $output = await $this->getManifestPath($path);

    return $output ?? $path;
  }

  private async function getManifestPath(string $path): Awaitable<?string> {
    if ($this->manifestData is null) {
      $manifest = new Filesystem\File($this->manifest);
      if (!$manifest->exists()) {
        throw new Exception\RuntimeException(Str\format(
          'Asset manifest file "%s" does not exist.',
          $manifest->path()->toString(),
        ));
      }

      $this->manifestData = Json\structure(
        await $manifest->read(),
        type_structure($this, 'TManifest'),
      );
    }

    return $this->manifestData[$path] ?? null;
  }
}
