namespace Nuxed\Test\Asset;

use namespace Nuxed\Asset;
use type Facebook\HackTest\HackTest;
use type Facebook\HackTest\DataProvider;
use function Facebook\FBExpect\expect;

class PackageTest extends HackTest {

  <<DataProvider('providePackages')>>
  public async function testGetUrl(
    ?string $version,
    string $format,
    string $path,
    string $expected,
  ): Awaitable<void> {
    $package = new Asset\Package(
      $version is nonnull
        ? new Asset\VersionStrategy\StaticVersionStrategy($version, $format)
        : new Asset\VersionStrategy\EmptyVersionStrategy(),
    );

    expect(await $package->getUrl($path))->toBeSame($expected);
  }

  <<DataProvider('providePackages')>>
  public async function testGetVersion(
    ?string $version,
    string $format,
    string $path,
    string $expected,
  ): Awaitable<void> {
    $package = new Asset\Package(
      $version is nonnull
        ? new Asset\VersionStrategy\StaticVersionStrategy($version, $format)
        : new Asset\VersionStrategy\EmptyVersionStrategy(),
    );

    expect(await $package->getVersion($path))->toBeSame(
      $version is nonnull ? $version : '',
    );
  }

  public function providePackages(
  ): Container<(?string, string, string, string)> {
    return vec[
      tuple('v1', '', 'http://example.com/foo', 'http://example.com/foo'),
      tuple('v1', '', 'https://example.com/foo', 'https://example.com/foo'),
      tuple('v1', '', '//example.com/foo', '//example.com/foo'),
      tuple(null, '', '/foo', '/foo'),
      tuple(null, '', 'foo', 'foo'),
      tuple('v1', 'version-%2$s/%1$s', '/foo', '/version-v1/foo'),
      tuple('v1', 'version-%2$s/%1$s', 'foo', 'version-v1/foo'),
      tuple('v1', 'version-%2$s/%1$s', 'foo/', 'version-v1/foo/'),
      tuple('v1', 'version-%2$s/%1$s', '/foo/', '/version-v1/foo/'),
      tuple('v2', 'version-%2$s/%1$s', '/foo/', '/version-v2/foo/'),
    ];
  }
}
