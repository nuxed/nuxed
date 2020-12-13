namespace Nuxed\Asset;

use namespace HH\Lib\{C, Str};

final class Packages implements IPackage {
  private dict<string, IPackage> $packages;

  /**
   * @param IPackage                          $defaultPackage The default package
   * @param KeyedContainer<string, IPackage>  $packages Additional packages indexed by name
   */
  public function __construct(
    private ?IPackage $defaultPackage = null,
    KeyedContainer<string, IPackage> $packages = dict[],
  ) {
    $this->packages = dict($packages);
  }

  public function setDefaultPackage(IPackage $defaultPackage): void {
    $this->defaultPackage = $defaultPackage;
  }

  /**
   * Adds a package.
   */
  public function addPackage(string $name, IPackage $package): void {
    $this->packages[$name] = $package;
  }

  /**
   * Returns an asset package.
   *
   * @param string $name The name of the package or null for the default package
   */
  public function getPackage(?string $name = null): IPackage {
    if ($name is null) {
      if ($this->defaultPackage is null) {
        throw new Exception\LogicException(
          'There is no default asset package, configure one first.',
        );
      }

      return $this->defaultPackage;
    }

    if (C\contains_key($this->packages, $name)) {
      return $this->packages[$name];
    } else {
      throw new Exception\InvalidArgumentException(
        Str\format('There is no "%s" asset package.', $name),
      );
    }
  }

  /**
   * Gets the version to add to public URL.
   */
  public async function getVersion(
    string $path,
    ?string $packageName = null,
  ): Awaitable<string> {
    return await $this->getPackage($packageName)->getVersion($path);
  }

  /**
   * Returns the public path.
   *
   * Absolute paths (i.e. http://...) are returned unmodified.
   *
   * @param string $path        A public path
   * @param string $packageName The name of the asset package to use
   */
  public async function getUrl(
    string $path,
    ?string $packageName = null,
  ): Awaitable<string> {
    return await $this->getPackage($packageName)->getUrl($path);
  }
}
