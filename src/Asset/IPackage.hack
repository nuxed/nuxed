namespace Nuxed\Asset;

interface IPackage {
  /**
   * Returns the asset version for an asset.
   */
  public function getVersion(string $asset): Awaitable<string>;

  /**
   * Returns an absolute or root-relative public path.
   */
  public function getUrl(string $path): Awaitable<string>;
}
