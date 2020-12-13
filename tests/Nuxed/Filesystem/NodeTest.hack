namespace Nuxed\Test\Filesystem;

use namespace HH\Asio;
use namespace Nuxed\Filesystem;
use type Facebook\HackTest\HackTest;
use type Facebook\HackTest\DataProvider;
use function Facebook\FBExpect\expect;

class NodeTest extends HackTest {
  use IoTestTrait;

  <<DataProvider('provideLoadFileData')>>
  public function testLoadFile(Filesystem\Path $file): void {
    expect(Filesystem\Node::load($file->toString()))->toBeInstanceOf(
      Filesystem\File::class,
    );
  }

  public async function provideLoadFileData(
  ): Awaitable<Container<(Filesystem\Path)>> {
    return vec[
      tuple(Filesystem\Path::create(__FILE__)),
      tuple(Filesystem\Path::create(__DIR__.'/PathTest.hack')),
      tuple(await static::createFile() |> $$->path()),
      tuple(await static::createSymlink() |> $$->path()),
    ];
  }

  <<DataProvider('provideLoadFolderData')>>
  public function testLoadFolder(Filesystem\Path $folder): void {
    expect(Filesystem\Node::load($folder->toString()))->toBeInstanceOf(
      Filesystem\Folder::class,
    );
  }

  public async function provideLoadFolderData(
  ): Awaitable<Container<(Filesystem\Path)>> {
    return vec[
      tuple(Filesystem\Path::create(__DIR__)),
      tuple(Filesystem\Path::create(__DIR__.'/..')),
      tuple(await static::createFolder() |> $$->path()),
      tuple(static::temporaryFolder()->path()),
    ];
  }

  public function testLoadThrowsForNonExistingPath(): void {
    expect(() ==> Filesystem\Node::load('missing'))
      ->toThrow(
        Filesystem\Exception\MissingNodeException::class,
        'Node (missing) doesn\'t exist.',
      );
  }

  <<DataProvider('provideDestoryData')>>
  public async function testDestory(Filesystem\Path $path): Awaitable<void> {
    expect($path->exists())->toBeTrue();
    $result = await Filesystem\Node::destroy($path->toString());
    expect($result)->toBeTrue();
    expect($path->exists())->toBeFalse();
  }

  public async function provideDestoryData(
  ): Awaitable<Container<(Filesystem\Path)>> {
    return vec[
      tuple(await static::createFile() |> $$->path()),
      tuple(await static::createFolder() |> $$->path()),
      tuple(await static::createSymlink() |> $$->path()),
    ];
  }

  public function testDestoryThrowsForMissinPath(): void {
    expect(async () ==> {
      await Filesystem\Node::destroy(static::createPath()->toString());
    })->toThrow(Filesystem\Exception\MissingNodeException::class);
  }
}
