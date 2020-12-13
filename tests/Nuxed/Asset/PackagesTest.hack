namespace Nuxed\Test\Asset;

use namespace Nuxed\Asset;
use type Facebook\HackTest\HackTest;
use function Facebook\FBExpect\expect;

class PackagesTest extends HackTest {
  public function testConstruct(): void {
    $foo = new Asset\Package(new Asset\VersionStrategy\EmptyVersionStrategy());
    $bar = new Asset\Package(new Asset\VersionStrategy\EmptyVersionStrategy());
    $packages = new Asset\Packages($foo, dict[
      'bar' => $bar,
    ]);
    expect($packages->getPackage())->toBeSame($foo);
    expect($packages->getPackage('bar'))->toBeSame($bar);
  }

  public function testGetterSetters(): void {
    $foo = new Asset\Package(new Asset\VersionStrategy\EmptyVersionStrategy());
    $bar = new Asset\Package(new Asset\VersionStrategy\EmptyVersionStrategy());
    $packages = new Asset\Packages();
    $packages->setDefaultPackage($foo);
    $packages->addPackage('bar', $bar);
    expect($packages->getPackage())->toBeSame($foo);
    expect($packages->getPackage('bar'))->toBeSame($bar);
  }

  public async function testGetVersion(): Awaitable<void> {
    $packages = new Asset\Packages(
      new Asset\Package(
        new Asset\VersionStrategy\StaticVersionStrategy('default'),
      ),
      dict[
        'a' => new Asset\Package(
          new Asset\VersionStrategy\StaticVersionStrategy('a'),
        ),
      ],
    );
    $url = await $packages->getVersion('/foo');
    expect($url)->toBeSame('default');
    $url = await $packages->getVersion('/foo', 'a');
    expect($url)->toBeSame('a');
  }

  public async function testGetUrl(): Awaitable<void> {
    $packages = new Asset\Packages(
      new Asset\Package(
        new Asset\VersionStrategy\StaticVersionStrategy('default'),
      ),
      dict[
        'a' => new Asset\Package(
          new Asset\VersionStrategy\StaticVersionStrategy('a'),
        ),
      ],
    );
    $url = await $packages->getUrl('/foo');
    expect($url)->toBeSame('/foo?default');
    $url = await $packages->getUrl('/foo', 'a');
    expect($url)->toBeSame('/foo?a');
  }

  public function testNoDefaultPackage(): void {
    $this->setExpectedException(
      Asset\Exception\LogicException::class,
      'There is no default asset package, configure one first.',
    );

    $packages = new Asset\Packages();
    $packages->getPackage();
  }

  public function testUndefinedPackage(): void {
    $this->setExpectedException(
      Asset\Exception\InvalidArgumentException::class,
      'There is no "foo" asset package.',
    );

    $packages = new Asset\Packages();
    $packages->getPackage('foo');
  }
}
