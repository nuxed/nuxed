namespace Nuxed\Test\Crypto\Asymmetric;

use namespace HH\Lib\Str;
use namespace HH\Lib\File;
use namespace Facebook\HackTest;
use namespace Nuxed\Crypto;
use namespace Nuxed\Crypto\Asymmetric;
use namespace HH\Lib\SecureRandom;
use function Facebook\FBExpect\expect;

class AuthenticationTest extends HackTest\HackTest {
  public async function testSignAndVerify(): Awaitable<void> {
    $key = await $this->import<
      Asymmetric\Authentication\Key\SignaturePrivateKey,
    >('asymmetric.authentication.private');
    $publicKey = await $this->import<
      Asymmetric\Authentication\Key\SignaturePublicKey,
    >('asymmetric.authentication.public');
    $signature = Asymmetric\Authentication\sign('Hello, World!', $key);

    expect(Crypto\Binary\length($signature))->toBeSame(
      \SODIUM_CRYPTO_SIGN_BYTES,
    );
    expect(Crypto\Hex\encode($signature))
      ->toBeSame(
        'ded3736f32e6cbd625fc6ec12521194dfad0192556baba67bc151f78707d00369cda8c910531bcfc49ac24ade1797ecb9f88eb53e31738fd174d7b4ee7ac8e07',
      );
    expect(
      Asymmetric\Authentication\verify('Hello, World!', $publicKey, $signature),
    )
      ->toBeTrue();
    expect(
      Asymmetric\Authentication\verify('Hello, World', $publicKey, $signature),
    )
      ->toBeFalse();
  }

  public async function testLockAndUnlock(): Awaitable<void> {
    $aliceSignaturePrivateKey = await $this->import<
      Asymmetric\Authentication\Key\SignaturePrivateKey,
    >('asymmetric.authentication.private');
    $aliceSignaturePublicKey = await $this->import<
      Asymmetric\Authentication\Key\SignaturePublicKey,
    >('asymmetric.authentication.public');
    $aliceEncryptionPrivateKey = await $this->import<
      Asymmetric\Encryption\Key\PrivateKey,
    >('asymmetric.encryption.private');
    $aliceEncryptionPublicKey = await $this->import<
      Asymmetric\Encryption\Key\PublicKey,
    >('asymmetric.encryption.public');

    $bobSignaturePrivateKey = await $this->import<
      Asymmetric\Authentication\Key\SignaturePrivateKey,
    >('bob.asymmetric.authentication.private');
    $bobSignaturePublicKey = await $this->import<
      Asymmetric\Authentication\Key\SignaturePublicKey,
    >('bob.asymmetric.authentication.public');
    $bobEncryptionPrivateKey = await $this->import<
      Asymmetric\Encryption\Key\PrivateKey,
    >('bob.asymmetric.encryption.private');
    $bobEncryptionPublicKey = await $this->import<
      Asymmetric\Encryption\Key\PublicKey,
    >('bob.asymmetric.encryption.public');

    // Actor : alice
    $toBob = Asymmetric\Authentication\lock(
      new Crypto\HiddenString('Hello Bob, This is Alice!'),
      $aliceSignaturePrivateKey,
      $bobEncryptionPublicKey,
    );

    // Actor : bob
    $recievedFromAlice = Asymmetric\Authentication\unlock(
      $toBob,
      $aliceSignaturePublicKey,
      $bobEncryptionPrivateKey,
    );

    expect($recievedFromAlice->toString())->toBeSame(
      'Hello Bob, This is Alice!',
    );

    $toAlice = Asymmetric\Authentication\lock(
      new Crypto\HiddenString('Hey Alice, long time no see!'),
      $bobSignaturePrivateKey,
      $aliceEncryptionPublicKey,
    );

    // Actor : alice
    $recievedFromBob = Asymmetric\Authentication\unlock(
      $toAlice,
      $bobSignaturePublicKey,
      $aliceEncryptionPrivateKey,
    );

    expect($recievedFromBob->toString())->toBeSame(
      'Hey Alice, long time no see!',
    );
  }

  <<HackTest\DataProvider('provideRandomStrings')>>
  public async function testSignAndVerifyRandom(string $data): Awaitable<void> {
    list($key, $publicKey) = Asymmetric\Authentication\SignatureKey::generate();

    $signature = Asymmetric\Authentication\sign($data, $key);
    expect(Crypto\Binary\length($signature))->toBeSame(
      \SODIUM_CRYPTO_SIGN_BYTES,
    );
    expect(Asymmetric\Authentication\verify($data, $publicKey, $signature))
      ->toBeTrue();
  }

  <<HackTest\DataProvider('provideRandomStrings')>>
  public async function testLockAndUnlockRandom(string $data): Awaitable<void> {
    list($aliceSignatureKey, $aliceSignaturePublicKey) =
      Asymmetric\Authentication\SignatureKey::generate();

    list($aliceEncKey, $aliceEncPublicKey) =
      Asymmetric\Encryption\Key::generate();

    list($bobSignatureKey, $bobSignaturePublicKey) =
      Asymmetric\Authentication\SignatureKey::generate();

    list($bobEncKey, $bobEncPublicKey) = Asymmetric\Encryption\Key::generate();

    // Actor : alice
    $toBob = Asymmetric\Authentication\lock(
      new Crypto\HiddenString($data),
      $aliceSignatureKey,
      $bobEncPublicKey,
    );

    // Actor : bob
    $recievedFromAlice = Asymmetric\Authentication\unlock(
      $toBob,
      $aliceSignaturePublicKey,
      $bobEncKey,
    );

    expect($recievedFromAlice->toString())->toBeSame($data);

    $toAlice = Asymmetric\Authentication\lock(
      new Crypto\HiddenString(Str\reverse($recievedFromAlice->toString())),
      $bobSignatureKey,
      $aliceEncPublicKey,
    );

    // Actor : alice
    $recievedFromBob = Asymmetric\Authentication\unlock(
      $toAlice,
      $bobSignaturePublicKey,
      $aliceEncKey,
    );

    expect($recievedFromBob->toString())->toBeSame(
      Str\reverse($recievedFromAlice->toString()),
    );
  }

  public function provideRandomStrings(): Container<(string)> {
    $ret = vec[];
    for ($i = 0; $i < 100; $i++) {
      $ret[] = tuple(Crypto\Hex\encode(SecureRandom\string(($i + 5) * 8)));
    }

    return $ret;
  }

  private async function import<reify T as Asymmetric\Key>(
    string $name,
  ): Awaitable<T> {
    $file = File\open_read_only(__DIR__.'/../../../keys/'.$name.'.key');
    using $file->closeWhenDisposed();

    return T::import(new Crypto\HiddenString(await $file->readAllAsync()));
  }
}
