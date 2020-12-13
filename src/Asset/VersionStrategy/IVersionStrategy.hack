namespace Nuxed\Asset\VersionStrategy;

interface IVersionStrategy {
  /**
   * Returns the asset version for an asset.
   */
  public function getVersion(string $asset): Awaitable<string>;

  /**
   * Applies version to the supplied path.
   */
  public function applyVersion(string $path): Awaitable<string>;
}
