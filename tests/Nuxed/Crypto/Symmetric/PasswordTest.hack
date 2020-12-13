namespace Nuxed\Test\Crypto\Symmetric;

use namespace HH\Lib\Str;
use namespace HH\Lib\File;
use namespace Facebook\HackTest;
use namespace Nuxed\Crypto;
use namespace Nuxed\Crypto\Symmetric;
use namespace HH\Lib\SecureRandom;
use function Facebook\FBExpect\expect;

class PasswordTest extends HackTest\HackTest {
  public async function testKeyRotation(): Awaitable<void> {
    $key = await $this->import<Symmetric\Encryption\Key>(
      'symmetric.encryption',
    );
    $otherKey = Symmetric\Encryption\Key::generate();

    $password = new Crypto\HiddenString('MYR3!!Y$tr0NGP4$sW0Rd');

    $interactive = Symmetric\Password\hash(
      $password,
      $key,
      Crypto\SecurityLevel::INTERACTIVE,
    );
    $moderate = Symmetric\Password\hash(
      $password,
      $key,
      Crypto\SecurityLevel::MODERATE,
    );
    $sensitive = Symmetric\Password\hash(
      $password,
      $key,
      Crypto\SecurityLevel::SENSITIVE,
    );

    expect(Symmetric\Password\verify($password, $interactive, $key))
      ->toBeTrue();
    expect(Symmetric\Password\verify($password, $moderate, $key))
      ->toBeTrue();
    expect(Symmetric\Password\verify($password, $sensitive, $key))
      ->toBeTrue();
    expect(() ==> Symmetric\Password\verify($password, $interactive, $otherKey))
      ->toThrow(Crypto\Exception\InvalidMessageException::class);
    expect(() ==> Symmetric\Password\verify($password, $moderate, $otherKey))
      ->toThrow(Crypto\Exception\InvalidMessageException::class);
    expect(() ==> Symmetric\Password\verify($password, $sensitive, $otherKey))
      ->toThrow(Crypto\Exception\InvalidMessageException::class);

    $newInteractive = Symmetric\Password\rotate($interactive, $key, $otherKey);
    $newModerate = Symmetric\Password\rotate($moderate, $key, $otherKey);
    $newSensitive = Symmetric\Password\rotate($sensitive, $key, $otherKey);

    expect(() ==> Symmetric\Password\verify($password, $newInteractive, $key))
      ->toThrow(Crypto\Exception\InvalidMessageException::class);
    expect(() ==> Symmetric\Password\verify($password, $newModerate, $key))
      ->toThrow(Crypto\Exception\InvalidMessageException::class);
    expect(() ==> Symmetric\Password\verify($password, $newSensitive, $key))
      ->toThrow(Crypto\Exception\InvalidMessageException::class);
    expect(Symmetric\Password\verify($password, $newInteractive, $otherKey))
      ->toBeTrue();
    expect(Symmetric\Password\verify($password, $newModerate, $otherKey))
      ->toBeTrue();
    expect(Symmetric\Password\verify($password, $newSensitive, $otherKey))
      ->toBeTrue();
  }

  <<HackTest\DataProvider('provideRandomPasswords')>>
  public function testRandom(Crypto\HiddenString $password): void {
    $key = Symmetric\Encryption\Key::generate();
    $otherKey = Symmetric\Encryption\Key::generate();

    $interactive = Symmetric\Password\hash(
      $password,
      $key,
      Crypto\SecurityLevel::INTERACTIVE,
    );
    $moderate = Symmetric\Password\hash(
      $password,
      $key,
      Crypto\SecurityLevel::MODERATE,
    );
    $sensitive = Symmetric\Password\hash(
      $password,
      $key,
      Crypto\SecurityLevel::SENSITIVE,
    );

    expect(Symmetric\Password\verify($password, $interactive, $key))
      ->toBeTrue();
    expect(Symmetric\Password\verify($password, $moderate, $key))
      ->toBeTrue();
    expect(Symmetric\Password\verify($password, $sensitive, $key))
      ->toBeTrue();
    expect(() ==> Symmetric\Password\verify($password, $interactive, $otherKey))
      ->toThrow(Crypto\Exception\InvalidMessageException::class);
    expect(() ==> Symmetric\Password\verify($password, $moderate, $otherKey))
      ->toThrow(Crypto\Exception\InvalidMessageException::class);
    expect(() ==> Symmetric\Password\verify($password, $sensitive, $otherKey))
      ->toThrow(Crypto\Exception\InvalidMessageException::class);

    expect(Symmetric\Password\stale(
      $interactive,
      $key,
      Crypto\SecurityLevel::INTERACTIVE,
    ))->toBeFalse();
    expect(Symmetric\Password\stale(
      $interactive,
      $key,
      Crypto\SecurityLevel::MODERATE,
    ))->toBeTrue();
    expect(Symmetric\Password\stale(
      $interactive,
      $key,
      Crypto\SecurityLevel::SENSITIVE,
    ))->toBeTrue();
    expect(
      () ==> Symmetric\Password\stale(
        $interactive,
        $otherKey,
        Crypto\SecurityLevel::MODERATE,
      ),
    )->toThrow(Crypto\Exception\InvalidMessageException::class);
    expect(
      () ==> Symmetric\Password\stale(
        $interactive,
        $otherKey,
        Crypto\SecurityLevel::SENSITIVE,
      ),
    )
      ->toThrow(Crypto\Exception\InvalidMessageException::class);
    expect(Symmetric\Password\stale(
      $moderate,
      $key,
      Crypto\SecurityLevel::INTERACTIVE,
    ))->toBeTrue();
    expect(
      () ==> Symmetric\Password\stale(
        $moderate,
        $otherKey,
        Crypto\SecurityLevel::INTERACTIVE,
      ),
    )
      ->toThrow(Crypto\Exception\InvalidMessageException::class);
    expect(
      Symmetric\Password\stale($moderate, $key, Crypto\SecurityLevel::MODERATE),
    )->toBeFalse();
    expect(Symmetric\Password\stale(
      $moderate,
      $key,
      Crypto\SecurityLevel::SENSITIVE,
    ))->toBeTrue();
    expect(
      () ==> Symmetric\Password\stale(
        $moderate,
        $otherKey,
        Crypto\SecurityLevel::SENSITIVE,
      ),
    )
      ->toThrow(Crypto\Exception\InvalidMessageException::class);
    expect(Symmetric\Password\stale(
      $sensitive,
      $key,
      Crypto\SecurityLevel::INTERACTIVE,
    ))->toBeTrue();
    expect(Symmetric\Password\stale(
      $sensitive,
      $key,
      Crypto\SecurityLevel::MODERATE,
    ))->toBeTrue();
    expect(
      () ==> Symmetric\Password\stale(
        $sensitive,
        $otherKey,
        Crypto\SecurityLevel::INTERACTIVE,
      ),
    )
      ->toThrow(Crypto\Exception\InvalidMessageException::class);
    expect(
      () ==> Symmetric\Password\stale(
        $sensitive,
        $otherKey,
        Crypto\SecurityLevel::MODERATE,
      ),
    )
      ->toThrow(Crypto\Exception\InvalidMessageException::class);
    expect(Symmetric\Password\stale(
      $sensitive,
      $key,
      Crypto\SecurityLevel::SENSITIVE,
    ))->toBeFalse();
  }

  public function provideRandomPasswords(): Container<(Crypto\HiddenString)> {
    $passwords = vec[];
    for ($i = 1; $i < 7; $i++) {
      $passwords[] = tuple(
        new Crypto\HiddenString(SecureRandom\string($i * 6)),
      );
    }
    return $passwords;
  }

  private async function import<reify T as Symmetric\Key>(
    string $name,
  ): Awaitable<T> {
    $file = File\open_read_only(__DIR__.'/../../../keys/'.$name.'.key');
    using $file->closeWhenDisposed();

    return T::import(new Crypto\HiddenString(await $file->readAsync()));
  }
}
