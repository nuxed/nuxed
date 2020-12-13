namespace Nuxed\Asset\VersionStrategy;

use namespace HH\Lib\Str;

final class StaticVersionStrategy implements IVersionStrategy {
  private string $format;

  /**
   * @param string $version Version number
   * @param string $format  Url format
   */
  public function __construct(private string $version, ?string $format = null) {
    $this->format = $format is nonnull && $format !== '' ? $format : '%s?%s';
  }

  /**
   * {@inheritdoc}
   */
  public async function getVersion(string $_path): Awaitable<string> {
    return $this->version;
  }

  /**
   * {@inheritdoc}
   */
  public async function applyVersion(string $path): Awaitable<string> {
    $versionized = Str\format(
      /* HH_IGNORE_ERROR[4027] */
      /* HH_IGNORE_ERROR[4110] */
      $this->format,
      Str\trim_left($path, '/'),
      await $this->getVersion($path),
    );

    if ('' !== $path && '/' === $path[0]) {
      return '/'.$versionized;
    }

    return $versionized;
  }
}
