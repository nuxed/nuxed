namespace Nuxed\Test\Asset;

use namespace Nuxed\Asset;
use type Facebook\HackTest\HackTest;
use type Facebook\HackTest\DataProvider;
use function Facebook\FBExpect\expect;

class PathPackageTest extends HackTest {

  <<DataProvider('providePackages')>>
  public async function testGetUrl(
    string $basePath,
    string $format,
    string $path,
    string $expected,
  ): Awaitable<void> {
    $package = new Asset\PathPackage(
      $basePath,
      new Asset\VersionStrategy\StaticVersionStrategy('v1', $format),
    );
    expect(await $package->getUrl($path))->toBeSame($expected);
  }

  public function providePackages(
  ): Container<(string, string, string, string)> {
    return vec[
      tuple('/foo', '', 'http://example.com/foo', 'http://example.com/foo'),
      tuple('/foo', '', 'https://example.com/foo', 'https://example.com/foo'),
      tuple('/foo', '', '//example.com/foo', '//example.com/foo'),
      tuple('', '', '/foo', '/foo?v1'),
      tuple('/foo', '', '/bar', '/bar?v1'),
      tuple('/foo', '', 'bar', '/foo/bar?v1'),
      tuple('foo', '', 'bar', '/foo/bar?v1'),
      tuple('foo/', '', 'bar', '/foo/bar?v1'),
      tuple('/foo/', '', 'bar', '/foo/bar?v1'),
      tuple('/foo', 'version-%2$s/%1$s', '/bar', '/version-v1/bar'),
      tuple('/foo', 'version-%2$s/%1$s', 'bar', '/foo/version-v1/bar'),
      tuple('/foo', 'version-%2$s/%1$s', 'bar/', '/foo/version-v1/bar/'),
      tuple('/foo', 'version-%2$s/%1$s', '/bar/', '/version-v1/bar/'),
    ];
  }

  <<DataProvider('provideContext')>>
  public async function testGetUrlWithContext(
    string $basePathRequest,
    string $basePath,
    string $format,
    string $path,
    string $expected,
  ): Awaitable<void> {
    $package = new Asset\PathPackage(
      $basePath,
      new Asset\VersionStrategy\StaticVersionStrategy('v1', $format),
      $this->getContextProvider($basePathRequest),
    );
    expect(await $package->getUrl($path))->toBeSame($expected);
  }

  public function provideContext(
  ): Container<(string, string, string, string, string)> {
    return vec[
      tuple('', '/foo', '', '/baz', '/baz?v1'),
      tuple('', '/foo', '', 'baz', '/foo/baz?v1'),
      tuple('', 'foo', '', 'baz', '/foo/baz?v1'),
      tuple('', 'foo/', '', 'baz', '/foo/baz?v1'),
      tuple('', '/foo/', '', 'baz', '/foo/baz?v1'),
      tuple('/bar', '/foo', '', '/baz', '/baz?v1'),
      tuple('/bar', '/foo', '', 'baz', '/bar/foo/baz?v1'),
      tuple('/bar', 'foo', '', 'baz', '/bar/foo/baz?v1'),
      tuple('/bar', 'foo/', '', 'baz', '/bar/foo/baz?v1'),
      tuple('/bar', '/foo/', '', 'baz', '/bar/foo/baz?v1'),
    ];
  }

  public async function testVersionStrategyGivesAbsoluteURL(): Awaitable<void> {
    $versionStrategy = new Asset\VersionStrategy\StaticVersionStrategy(
      '',
      'https://cdn.com/bar/%s?%s',
    );
    $package = new Asset\PathPackage(
      '/subdirectory',
      $versionStrategy,
      $this->getContextProvider('/bar'),
    );
    expect(await $package->getUrl('main.css'))->toBeSame(
      'https://cdn.com/bar/main.css?',
    );
  }

  private function getContextProvider(
    string $base_path,
    bool $secure = false,
  ): Asset\Context\IContextProvider {
    return Asset\Context\ContextProvider::create($base_path, $secure);
  }
}
