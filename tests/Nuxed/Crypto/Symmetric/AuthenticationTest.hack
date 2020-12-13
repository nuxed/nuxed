namespace Nuxed\Test\Crypto\Symmetric;

use namespace HH\Lib\Str;
use namespace HH\Lib\File;
use namespace Facebook\HackTest;
use namespace Nuxed\Crypto;
use namespace Nuxed\Crypto\Symmetric;
use namespace HH\Lib\SecureRandom;
use function Facebook\FBExpect\expect;

class AuthenticationTest extends HackTest\HackTest {
  public async function testAuthenticateAndVerify(): Awaitable<void> {
    $key = await $this->import<Symmetric\Authentication\SignatureKey>(
      'symmetric.authentication',
    );

    $mac = Symmetric\Authentication\authenticate('Hello, World!', $key);

    expect(Str\length($mac))->toBeSame(\SODIUM_CRYPTO_GENERICHASH_BYTES_MAX);
    expect(Crypto\Hex\encode($mac))
      ->toBeSame(
        '1c7f53d7df6dc916d72ac924cf7cb37efa7c236c05d6a3b2257806dd24aeba88c38ebad236b2ee4005866ffeabe67a75845f4da8309cf9ca8e9602c446e48b9b',
      );
    expect(Symmetric\Authentication\verify('Hello, World!', $key, $mac))
      ->toBeTrue();
    expect(Symmetric\Authentication\verify('Hello, World', $key, $mac))
      ->toBeFalse();
  }

  <<HackTest\DataProvider('provideRandomStrings')>>
  public async function testAuthenticateAndVerifyRandom(
    string $data,
  ): Awaitable<void> {
    $key = Symmetric\Authentication\SignatureKey::generate();

    $mac = Symmetric\Authentication\authenticate($data, $key);

    expect(Str\length($mac))->toBeSame(\SODIUM_CRYPTO_GENERICHASH_BYTES_MAX);
    expect(Symmetric\Authentication\verify($data, $key, $mac))
      ->toBeTrue();
    expect(Symmetric\Authentication\verify(Str\slice($data, 1), $key, $mac))
      ->toBeFalse();
  }

  public function provideRandomStrings(): Container<(string)> {
    $ret = vec[];
    for ($i = 0; $i < 100; $i++) {
      $ret[] = tuple(Crypto\Hex\encode(SecureRandom\string(($i + 5) * 8)));
    }

    return $ret;
  }

  private async function import<reify T as Symmetric\Key>(
    string $name,
  ): Awaitable<T> {
    $file = File\open_read_only(__DIR__.'/../../../keys/'.$name.'.key');
    using $file->closeWhenDisposed();

    return T::import(new Crypto\HiddenString(await $file->readAsync()));
  }
}
