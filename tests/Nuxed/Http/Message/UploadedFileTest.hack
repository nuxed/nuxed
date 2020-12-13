namespace Nuxed\Test\Http\Message;

use namespace Nuxed\Filesystem;
use namespace Nuxed\Http\Message;
use namespace Nuxed\Contract\Http;
use namespace Facebook\HackTest;
use function Facebook\FBExpect\expect;

class UploadedFileTest extends HackTest\HackTest {
  public async function testSuccessful(): Awaitable<void> {
    concurrent {
      $source = await Filesystem\File::temporary('source');
      $target = await Filesystem\File::temporary('target');
    }

    await $source->write('foo bar');
    $upload = new Message\UploadedFile(
      $source->path()->toString(),
      await $source->size(),
      Http\Message\UploadedFileError::None,
      'filename.txt',
      'text/plain',
    );

    expect($upload->getSize())->toBeSame(await $source->size());
    expect($upload->getClientFilename())->toBeSame('filename.txt');
    expect($upload->getClientMediaType())->toBeSame('text/plain');
    await $upload->move($target->path()->toString());
    expect(await $target->read())->toBeSame(await $source->read());
  }

  public async function testMoveCannotBeCalledMoreThanOnce(): Awaitable<void> {
    concurrent {
      $source = await Filesystem\File::temporary('source');
      $target = await Filesystem\File::temporary('target');
    }

    await $source->write('foo bar');
    $upload = new Message\UploadedFile(
      $source->path()->toString(),
      await $source->size(),
      Http\Message\UploadedFileError::None,
    );

    await $upload->move($target->path()->toString());
    expect(await $target->read())->toBeSame(await $source->read());
    expect($target->exists())->toBeTrue();
    expect(() ==> $upload->move($target->path()->toString()))
      ->toThrow(
        Message\Exception\UploadedFileAlreadyMovedException::class,
        'Cannot retrieve file handle after it has already moved',
      );
  }

  public async function testCannotRetrieveHandleAfterMove(): Awaitable<void> {
    concurrent {
      $source = await Filesystem\File::temporary('source');
      $target = await Filesystem\File::temporary('target');
    }

    await $source->write('foo bar');
    $upload = new Message\UploadedFile(
      $source->path()->toString(),
      await $source->size(),
      Http\Message\UploadedFileError::None,
    );

    await $upload->move($target->path()->toString());
    expect(await $target->read())->toBeSame(await $source->read());

    expect(() ==> {
      $upload->getHandle();
    })->toThrow(
      Message\Exception\UploadedFileAlreadyMovedException::class,
      'Cannot retrieve file handle after it has already moved.',
    );
  }

  public function nonOkErrorStatus(
  ): Container<(Http\Message\UploadedFileError)> {
    return vec[
      tuple(Http\Message\UploadedFileError::ExceedsMaxSize),
      tuple(Http\Message\UploadedFileError::ExceedsMaxFormSize),
      tuple(Http\Message\UploadedFileError::Incomplete),
      tuple(Http\Message\UploadedFileError::NoFile),
      tuple(Http\Message\UploadedFileError::TemporaryDirectoryNotSpecified),
      tuple(Http\Message\UploadedFileError::TemporaryDirectoryNotWritable),
      tuple(Http\Message\UploadedFileError::CanceledByExtension),
    ];
  }

  <<HackTest\DataProvider('nonOkErrorStatus')>>
  public function testConstructorDoesNotRaiseExceptionForInvalidHandleWhenErrorStatusPresent(
    Http\Message\UploadedFileError $status,
  ): void {
    $uploadedFile = new Message\UploadedFile('/path/to/file', 0, $status);
    expect($uploadedFile->getError())->toBeSame($status);
  }

  <<HackTest\DataProvider('nonOkErrorStatus')>>
  public function testMoveToRaisesExceptionWhenErrorStatusPresent(
    Http\Message\UploadedFileError $status,
  ): void {
    $uploadedFile = new Message\UploadedFile('/path/to/file', 0, $status);
    expect(async () ==> {
      $to = await Filesystem\File::temporary('test');
      await $uploadedFile->move($to->path()->toString());
    })->toThrow(
      Message\Exception\UploadedFileErrorException::class,
      'Cannot retrieve handle due to upload error',
    );
  }

  <<HackTest\DataProvider('nonOkErrorStatus')>>
  public function testGetHandleRaisesExceptionWhenErrorStatusPresent(
    Http\Message\UploadedFileError $status,
  ): void {
    $uploadedFile = new Message\UploadedFile('/path/to/file', 0, $status);
    expect(() ==> $uploadedFile->getHandle())->toThrow(
      Message\Exception\UploadedFileErrorException::class,
      'Cannot retrieve handle due to upload error',
    );
  }
}
