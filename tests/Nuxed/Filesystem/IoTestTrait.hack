namespace Nuxed\Test\Filesystem;

use namespace HH\Asio;
use namespace HH\Lib\PseudoRandom;
use namespace Nuxed\Filesystem;
use type Facebook\HackTest\HackTest;

trait IoTestTrait {
  require extends HackTest;
  public static async function beforeFirstTestAsync(): Awaitable<void> {
    $tmp = static::temporaryFolder();
    if (!$tmp->exists()) {
      await $tmp->create();
    }
  }

  public static async function afterLastTestAsync(): Awaitable<void> {
    $tmp = static::temporaryFolder();
    if ($tmp->exists()) {
      await $tmp->delete();
    }
  }

  protected static function temporaryFolder(): Filesystem\Folder {
    return new Filesystem\Folder(__DIR__.'/../../tmp/');
  }

  protected static function createPath(): Filesystem\Path {
    $path = __DIR__.
      '/../../tmp/'.
      PseudoRandom\string(64, 'qwertyuiopasdfghjklzxcvbnm123456789-');
    return Filesystem\Path::create($path);
  }

  protected static async function createFile(): Awaitable<Filesystem\File> {
    $file = new Filesystem\File(static::createPath()->toString());
    await $file->create();
    return $file;
  }

  protected static async function createFolder(): Awaitable<Filesystem\Folder> {
    $folder = new Filesystem\Folder(static::createPath()->toString());
    await $folder->create();
    return $folder;
  }

  protected static async function createSymlink(): Awaitable<Filesystem\File> {
    $file = await static::createFile();
    $symlink = static::createPath();
    $e = await $file->symlink($symlink->toString());
    return $e;
  }
}
