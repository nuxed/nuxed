namespace Nuxed\Asset;

use namespace HH\Lib\Str;

/**
 * Basic package that adds a version to asset URLs.
 */
<<__Sealed(UrlPackage::class, PathPackage::class)>>
class Package implements IPackage {
  private (function(): Context\IContext) $contextProvider;

  public function __construct(
    private VersionStrategy\IVersionStrategy $versionStrategy,
    ?Context\IContextProvider $contextProvider = null,
  ) {
    $this->contextProvider = (): Context\IContext ==> {
      if ($contextProvider is nonnull) {
        return $contextProvider->getContext();
      }

      return new Context\NullContext();
    };
  }

  /**
   * {@inheritdoc}
   */
  public async function getVersion(string $asset): Awaitable<string> {
    return await $this->versionStrategy->getVersion($asset);
  }

  /**
   * {@inheritdoc}
   */
  public async function getUrl(string $path): Awaitable<string> {
    if ($this->isAbsoluteUrl($path)) {
      return $path;
    }

    return await $this->versionStrategy->applyVersion($path);
  }

  protected function getContext(): Context\IContext {
    return ($this->contextProvider)();
  }

  protected function getVersionStrategy(): VersionStrategy\IVersionStrategy {
    return $this->versionStrategy;
  }

  protected function isAbsoluteUrl(string $url): bool {
    return Str\contains($url, '://') || Str\starts_with($url, '//');
  }
}
