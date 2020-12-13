namespace Nuxed\Test\Console\Command\Loader;

use namespace HH\Lib\C;
use namespace Facebook\HackTest;
use namespace Nuxed\Test\Fixture;
use namespace Nuxed\Console\Command\Loader;
use namespace Nuxed\Console\Exception;

use function Facebook\FBExpect\expect;

class FactoryLoaderTest extends HackTest\HackTest {
  public function testGetNames(): void {
    $loader = new Loader\FactoryLoader(dict[
      'hello:world' => () ==> new Fixture\HelloWorldCommand(),
    ]);

    $names = $loader->getNames();
    expect($names)->toContain('hello:world');
    expect(C\count($names))->toBeSame(1);
  }

  public function testHas(): void {
    $loader = new Loader\FactoryLoader(dict[
      'hello:world' => () ==> new Fixture\HelloWorldCommand(),
    ]);

    expect($loader->has('foo:bar'))->toBeFalse();
    expect($loader->has('hello:world'))->toBeTrue();
  }

  public function testGet(): void {
    $instance = new Fixture\HelloWorldCommand();
    $loader = new Loader\FactoryLoader(dict[
      'hello:world' => () ==> $instance,
    ]);

    expect($loader->get('hello:world'))->toBeSame($instance);
    $e = expect(() ==> $loader->get('bar:foo'))
      ->toThrow(Exception\InvalidCommandException::class);

    expect($e->getMessage())->toContainSubstring('bar:foo');
  }
}
