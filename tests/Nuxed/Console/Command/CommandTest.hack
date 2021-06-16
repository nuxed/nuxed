namespace Nuxed\Test\Console\Command;

use namespace HH\Lib\C;
use namespace Facebook\HackTest;
use namespace Nuxed\Test\Fixture;
use namespace Nuxed\Console\{Command, Exception};
use function Facebook\FBExpect\expect;

final class CommandTest extends HackTest\HackTest {
  public function testCommandThrowsForInvalidName(): void {
    // TODO(azjezz): fix this.
    // expect(() ==> new Fixture\HelloWorldCommand('foo bar'))->toThrow(
    //   Exception\InvalidCharacterSequenceException::class,
    // );
  }
}
