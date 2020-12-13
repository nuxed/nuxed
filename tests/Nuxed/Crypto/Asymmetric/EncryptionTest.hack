namespace Nuxed\Test\Crypto\Asymmetric;

use namespace HH\Lib\Str;
use namespace HH\Lib\File;
use namespace Facebook\HackTest;
use namespace Nuxed\Crypto;
use namespace Nuxed\Crypto\Asymmetric;
use namespace HH\Lib\SecureRandom;
use function Facebook\FBExpect\expect;

class EncryptionTest extends HackTest\HackTest {
  public async function testEncryptAndDecrypt(): Awaitable<void> {
    $aliceEncryptionPrivateKey = await $this->import<
      Asymmetric\Encryption\Key\PrivateKey,
    >('asymmetric.encryption.private');
    $aliceEncryptionPublicKey = await $this->import<
      Asymmetric\Encryption\Key\PublicKey,
    >('asymmetric.encryption.public');
    $bobEncryptionPrivateKey = await $this->import<
      Asymmetric\Encryption\Key\PrivateKey,
    >('bob.asymmetric.encryption.private');
    $bobEncryptionPublicKey = await $this->import<
      Asymmetric\Encryption\Key\PublicKey,
    >('bob.asymmetric.encryption.public');


    // Actor : alice
    $message = new Crypto\HiddenString('Hello Bob');
    $toBob = Asymmetric\Encryption\encrypt(
      $message,
      $aliceEncryptionPrivateKey,
      $bobEncryptionPublicKey,
    );

    // Actor : bob
    $fromAlice = Asymmetric\Encryption\decrypt(
      $toBob,
      $bobEncryptionPrivateKey,
      $aliceEncryptionPublicKey,
    );

    expect($fromAlice->toString())->toBeSame('Hello Bob');

    $message = new Crypto\HiddenString('Hey Alice');
    $toAlice = Asymmetric\Encryption\encrypt(
      $message,
      $bobEncryptionPrivateKey,
      $aliceEncryptionPublicKey,
    );

    // Actor : alice
    $fromBob = Asymmetric\Encryption\decrypt(
      $toAlice,
      $aliceEncryptionPrivateKey,
      $bobEncryptionPublicKey,
    );

    expect($fromBob->toString())->toBeSame('Hey Alice');
  }

  public async function testEncryptAndDecryptWithAD(): Awaitable<void> {
    $aliceEncryptionPrivateKey = await $this->import<
      Asymmetric\Encryption\Key\PrivateKey,
    >('asymmetric.encryption.private');
    $aliceEncryptionPublicKey = await $this->import<
      Asymmetric\Encryption\Key\PublicKey,
    >('asymmetric.encryption.public');
    $bobEncryptionPrivateKey = await $this->import<
      Asymmetric\Encryption\Key\PrivateKey,
    >('bob.asymmetric.encryption.private');
    $bobEncryptionPublicKey = await $this->import<
      Asymmetric\Encryption\Key\PublicKey,
    >('bob.asymmetric.encryption.public');

    $random = SecureRandom\string(32);

    $message = new Crypto\HiddenString('Hello Bob');
    $ciphertext = Asymmetric\Encryption\encrypt(
      $message,
      $aliceEncryptionPrivateKey,
      $bobEncryptionPublicKey,
      $random,
    );

    $plaintext = Asymmetric\Encryption\decrypt(
      $ciphertext,
      $bobEncryptionPrivateKey,
      $aliceEncryptionPublicKey,
      $random,
    );

    expect($plaintext->toString())->toBeSame('Hello Bob');

    try {
      Asymmetric\Encryption\decrypt(
        $ciphertext,
        $bobEncryptionPrivateKey,
        $aliceEncryptionPublicKey,
      );
      static::fail('AD did not change MAC');
    } catch (Crypto\Exception\IException $e) {
      expect($e is Crypto\Exception\InvalidMessageException)
        ->toBeTrue();
      expect($e->getMessage())
        ->toBeSame('Invalid message authentication code');
    }

    try {
      Asymmetric\Encryption\decrypt(
        $ciphertext,
        $bobEncryptionPrivateKey,
        $aliceEncryptionPublicKey,
        'wrong',
      );
      static::fail('AD did not change MAC');
    } catch (Crypto\Exception\IException $e) {
      expect($e is Crypto\Exception\InvalidMessageException)
        ->toBeTrue();
      expect($e->getMessage())
        ->toBeSame('Invalid message authentication code');
    }
  }

  public async function testEncryptAndDecryptEmpty(): Awaitable<void> {
    $aliceEncryptionPrivateKey = await $this->import<
      Asymmetric\Encryption\Key\PrivateKey,
    >('asymmetric.encryption.private');
    $aliceEncryptionPublicKey = await $this->import<
      Asymmetric\Encryption\Key\PublicKey,
    >('asymmetric.encryption.public');
    $bobEncryptionPrivateKey = await $this->import<
      Asymmetric\Encryption\Key\PrivateKey,
    >('bob.asymmetric.encryption.private');
    $bobEncryptionPublicKey = await $this->import<
      Asymmetric\Encryption\Key\PublicKey,
    >('bob.asymmetric.encryption.public');

    $message = new Crypto\HiddenString('');
    $ciphertext = Asymmetric\Encryption\encrypt(
      $message,
      $aliceEncryptionPrivateKey,
      $bobEncryptionPublicKey,
    );

    $plaintext = Asymmetric\Encryption\decrypt(
      $ciphertext,
      $bobEncryptionPrivateKey,
      $aliceEncryptionPublicKey,
    );

    expect($plaintext->toString())->toBeSame('');
  }

  public async function testEncryptAndDecryptFail(): Awaitable<void> {
    $aliceEncryptionPrivateKey = await $this->import<
      Asymmetric\Encryption\Key\PrivateKey,
    >('asymmetric.encryption.private');
    $aliceEncryptionPublicKey = await $this->import<
      Asymmetric\Encryption\Key\PublicKey,
    >('asymmetric.encryption.public');
    $bobEncryptionPrivateKey = await $this->import<
      Asymmetric\Encryption\Key\PrivateKey,
    >('bob.asymmetric.encryption.private');
    $bobEncryptionPublicKey = await $this->import<
      Asymmetric\Encryption\Key\PublicKey,
    >('bob.asymmetric.encryption.public');

    $message = new Crypto\HiddenString('test message');
    $ciphertext = Asymmetric\Encryption\encrypt(
      $message,
      $aliceEncryptionPrivateKey,
      $bobEncryptionPublicKey,
    );

    $r = SecureRandom\int(0, Crypto\Binary\length($ciphertext) - 1);
    $amt = SecureRandom\int(0, 7);
    $ciphertext[$r] = Crypto\Str\chr(
      Crypto\Str\ord($ciphertext[$r]) ^ 1 << $amt,
    );

    try {
      Asymmetric\Encryption\decrypt(
        $ciphertext,
        $bobEncryptionPrivateKey,
        $aliceEncryptionPublicKey,
      );

      static::fail('Should have thrown an InvalidMessageException!');
    } catch (Crypto\Exception\IException $e) {
      expect($e is Crypto\Exception\InvalidMessageException)
        ->toBeTrue();
      expect($e->getMessage())
        ->toBeSame('Invalid message authentication code');
    }
  }

  // Anonymous Encryption
  public async function testSealAndUnseal(): Awaitable<void> {
    $aliceEncryptionPrivateKey = await $this->import<
      Asymmetric\Encryption\Key\PrivateKey,
    >('asymmetric.encryption.private');
    $aliceEncryptionPublicKey = await $this->import<
      Asymmetric\Encryption\Key\PublicKey,
    >('asymmetric.encryption.public');

    expect($aliceEncryptionPublicKey->toString())
      ->toBeSame(
        \sodium_crypto_box_publickey_from_secretkey(
          $aliceEncryptionPrivateKey->toString(),
        ),
      );

    // Actor : anonymous
    $message = new Crypto\HiddenString('Hello Alice');
    $sealed = Asymmetric\Encryption\seal($message, $aliceEncryptionPublicKey);

    // Actor : alice
    $unsealed = Asymmetric\Encryption\unseal(
      $sealed,
      $aliceEncryptionPrivateKey,
    );

    expect($unsealed->toString())->toBeSame('Hello Alice');
  }

  public async function testSealAndUnsealFail(): Awaitable<void> {
    $aliceEncryptionPrivateKey = await $this->import<
      Asymmetric\Encryption\Key\PrivateKey,
    >('asymmetric.encryption.private');
    $aliceEncryptionPublicKey = await $this->import<
      Asymmetric\Encryption\Key\PublicKey,
    >('asymmetric.encryption.public');

    expect($aliceEncryptionPublicKey->toString())
      ->toBeSame(
        \sodium_crypto_box_publickey_from_secretkey(
          $aliceEncryptionPrivateKey->toString(),
        ),
      );

    // Actor : anonymous
    $message = new Crypto\HiddenString('Hello Alice');
    $sealed = Asymmetric\Encryption\seal($message, $aliceEncryptionPublicKey);

    // Actor : alice
    $unsealed = Asymmetric\Encryption\unseal(
      $sealed,
      $aliceEncryptionPrivateKey,
    );

    expect($unsealed->toString())->toBeSame('Hello Alice');

    $r = SecureRandom\int(0, Crypto\Binary\length($sealed) - 1);
    $amt = SecureRandom\int(0, 7);
    $sealed[$r] = Crypto\Str\chr(Crypto\Str\ord($sealed[$r]) ^ 1 << $amt);

    try {
      Asymmetric\Encryption\unseal($sealed, $aliceEncryptionPrivateKey);

      static::fail('should have thrown InvalidKeyException');
    } catch (Crypto\Exception\IException $e) {
      expect($e is Crypto\Exception\InvalidKeyException)
        ->toBeTrue();
      expect($e->getMessage())
        ->toBeSame('Incorrect private key for this sealed message');
    }
  }

  <<HackTest\DataProvider('provideRandomStrings')>>
  public async function testEncryptAndDecryptRandom(
    string $data,
  ): Awaitable<void> {
    list($aliceEncryptionPrivateKey, $aliceEncryptionPublicKey) =
      Asymmetric\Encryption\Key::generate();
    list($bobEncryptionPrivateKey, $bobEncryptionPublicKey) =
      Asymmetric\Encryption\Key::generate();

    // Actor : alice
    $message = new Crypto\HiddenString($data);
    $toBob = Asymmetric\Encryption\encrypt(
      $message,
      $aliceEncryptionPrivateKey,
      $bobEncryptionPublicKey,
    );

    // Actor : bob
    $fromAlice = Asymmetric\Encryption\decrypt(
      $toBob,
      $bobEncryptionPrivateKey,
      $aliceEncryptionPublicKey,
    );

    expect($fromAlice->toString())->toBeSame($data);

    $message = new Crypto\HiddenString(Str\reverse($data));
    $toAlice = Asymmetric\Encryption\encrypt(
      $message,
      $bobEncryptionPrivateKey,
      $aliceEncryptionPublicKey,
    );

    // Actor : alice
    $fromBob = Asymmetric\Encryption\decrypt(
      $toAlice,
      $aliceEncryptionPrivateKey,
      $bobEncryptionPublicKey,
    );

    expect($fromBob->toString())->toBeSame(Str\reverse($data));
  }

  <<HackTest\DataProvider('provideRandomStrings')>>
  public async function testSealAndUnsealRandom(string $data): Awaitable<void> {
    list($aliceEncryptionPrivateKey, $aliceEncryptionPublicKey) =
      Asymmetric\Encryption\Key::generate();

    // Actor : anonymous
    $message = new Crypto\HiddenString($data);
    $encrypted = Asymmetric\Encryption\seal(
      $message,
      $aliceEncryptionPublicKey,
    );

    // Actor : alice
    $recieved = Asymmetric\Encryption\unseal(
      $encrypted,
      $aliceEncryptionPrivateKey,
    );

    expect($recieved->toString())->toBeSame($data);
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
