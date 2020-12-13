namespace Nuxed\Test\Filesystem;

use namespace HH\Asio;
use namespace Nuxed\Filesystem;
use namespace HH\Lib\C;
use namespace HH\Lib\Tuple;
use type Facebook\HackTest\HackTest;
use type Facebook\HackTest\DataProvider;
use function Facebook\FBExpect\expect;

class FolderTest extends HackTest {
  use NodeTestTrait;

  <<DataProvider('provideMissingNodes')>>
  public async function testCreate(Filesystem\Folder $folder): Awaitable<void> {
    $ret = await $folder->create(0444);
    expect($ret)->toBeTrue();
    $permissions = $folder->permissions();
    expect($permissions)->toBeSame(0444);
  }

  <<DataProvider('provideNodes')>>
  public function testCreateThrowsIfFolderExists(
    Filesystem\Folder $folder,
  ): void {
    expect(async () ==> {
      expect($folder->exists())->toBeTrue();
      await $folder->create();
    })->toThrow(Filesystem\Exception\ExistingNodeException::class);
  }

  <<DataProvider('provideNodes')>>
  public async function testCopy(Filesystem\Folder $folder): Awaitable<void> {
    // create the target directory path.
    $target = static::createPath();
    // copy folder to the target directory.
    $copy = await $folder->copy(
      $target->toString(),
      Filesystem\OperationType::OVERWRITE,
      0711,
    );
    expect($copy)->toBeInstanceOf(Filesystem\Folder::class);
    $copy as Filesystem\Folder;
    expect($copy->exists())->toBeTrue();
    expect($copy->permissions())->toBeSame(0711);
  }

  <<DataProvider('provideMissingNodes')>>
  public function testCopyThrowsIfFolderDoesntExists(
    Filesystem\Folder $missing,
  ): void {
    expect(async () ==> {
      await $missing->copy(static::createPath()->toString());
    })->toThrow(Filesystem\Exception\MissingNodeException::class);
  }

  <<DataProvider('provideNodes')>>
  public async function testCopyWithContent(
    Filesystem\Folder $folder,
  ): Awaitable<void> {
    // create a file inside the folder.
    $file = await $folder->touch('foo.txt');
    $file as Filesystem\File;
    await $file->write('bar');

    // create the target directory path.
    $target = static::createPath();
    // copy folder to the target directory.
    $copy = await $folder->copy($target->toString());
    expect($copy)->toBeInstanceOf(Filesystem\Folder::class);
    $copy as Filesystem\Folder;

    expect($copy->exists())->toBeTrue();

    // read the files inside the copy.
    $content = await $copy->files();
    expect(C\count($content))->toBeSame(1);
    $copyFileContent = await C\firstx($content)->read();
    expect($copyFileContent)->toBeSame('bar');

    // delete the nodes we created.
    concurrent {
      await $copy->delete();
      await $file->delete();
    }
  }

  <<DataProvider('provideExistingNodesPair')>>
  public async function testCopyOverwrite(
    Filesystem\Folder $folder,
    Filesystem\Folder $target,
  ): Awaitable<void> {
    await $target->touch('foo.txt');
    $targetSize = await $target->size();
    expect($targetSize)->toBeSame(1);
    $copy = await $folder->copy(
      $target->path()->toString(),
      Filesystem\OperationType::OVERWRITE,
    );
    expect($copy->exists())->toBeTrue();
    $copy as Filesystem\Folder;
    concurrent {
      $folderSize = await $folder->size();
      $copySize = await $copy->size();
    }
    expect($copySize)->toNotBeSame($targetSize);
    expect($copySize)->toBeSame($folderSize);
  }

  <<DataProvider('provideExistingNodesPair')>>
  public async function testCopySkip(
    Filesystem\Folder $folder,
    Filesystem\Folder $target,
  ): Awaitable<void> {
    $foo = await $folder->touch('foo.txt');
    await $foo->write('foo');
    $bar = await $folder->touch('bar.txt');
    await $bar->write('bar');
    $baz = await $target->touch('foo.txt');
    await $baz->write('baz');
    concurrent {
      $folderSize = await $folder->size();
      $targetSize = await $target->size();
    }
    expect($folderSize)->toBeSame(2);
    expect($targetSize)->toBeSame(1);

    $copy = await $folder->copy(
      $target->path()->toString(),
      Filesystem\OperationType::SKIP,
    );
    concurrent {
      $folderSize = await $folder->size();
      $copySize = await $copy->size();
    }
    expect($copySize)->toNotBeSame($targetSize);
    expect($copySize)->toBeSame($folderSize);

    $content = await $baz->read();
    expect($content)->toBeSame('baz');
  }

  <<DataProvider('provideExistingNodesPair')>>
  public async function testCopyMerge(
    Filesystem\Folder $folder,
    Filesystem\Folder $target,
  ): Awaitable<void> {
    concurrent {
      await $folder->flush();
      await $target->flush();
    }
    $foo = await $folder->touch('foo.txt');
    await $foo->write('foo');
    $bar = await $folder->touch('bar.txt');
    await $bar->write('bar');
    await $target->touch('hip.txt');
    await $target->touch('hop.txt');
    $baz = await $target->touch('foo.txt');
    await $baz->write('baz');
    concurrent {
      $folderSize = await $folder->size();
      $targetSize = await $target->size();
    }
    expect($folderSize)->toBeSame(2);
    expect($targetSize)->toBeSame(3);

    $copy = await $folder->copy(
      $target->path()->toString(),
      Filesystem\OperationType::MERGE,
    );
    concurrent {
      $folderSize = await $folder->size();
      $copySize = await $copy->size();
    }
    expect($copySize)->toNotBeSame($targetSize);
    expect($copySize)->toBeSame(4);

    $content = await $baz->read();
    expect($content)->toBeSame('foo');
  }

  <<DataProvider('provideNodes')>>
  public async function testDelete(Filesystem\Folder $folder): Awaitable<void> {
    expect($folder->exists())->toBeTrue();
    $ret = await $folder->delete();
    expect($ret)->toBeTrue();
    expect($folder->exists())->toBeFalse();
  }

  <<DataProvider('provideMissingNodes')>>
  public function testDeleteThrowsIfFolderDoesntExist(
    Filesystem\Folder $folder,
  ): void {
    expect(async () ==> {
      expect($folder->exists())->toBeFalse();
      await $folder->delete();
    })->toThrow(Filesystem\Exception\MissingNodeException::class);
  }

  <<DataProvider('provideNodes')>>
  public async function testFlush(Filesystem\Folder $folder): Awaitable<void> {
    $foo = await $folder->touch('foo.txt');
    $bar = await $folder->mkdir('bar');
    $baz = await $bar->touch('baz.txt');
    expect($foo->exists())->toBeTrue();
    expect($bar->exists())->toBeTrue();
    expect($baz->exists())->toBeTrue();
    await $folder->flush();
    expect($foo->exists())->toBeFalse();
    expect($bar->exists())->toBeFalse();
    expect($baz->exists())->toBeFalse();
  }

  <<DataProvider('provideMissingNodes')>>
  public function testFlushThrowsIfFolderDoesntExist(
    Filesystem\Folder $folder,
  ): void {
    expect(async () ==> {
      expect($folder->exists())->toBeFalse();
      await $folder->delete();
    })->toThrow(Filesystem\Exception\MissingNodeException::class);
  }

  <<DataProvider('provideNodes')>>
  public async function testFind(Filesystem\Folder $folder): Awaitable<void> {
    await $folder->flush();
    concurrent {
      await $folder->touch('foo.txt');
      await $folder->touch('bar.txt');
      await $folder->touch('baz.txt');
      await $folder->touch('foo.bar.txt');
      await $folder->touch('bar.baz.txt');
      await $folder->touch('foo.bar.baz.txt');
      await $folder->mkdir('foo');
      await $folder->mkdir('bar');
      await $folder->mkdir('baz');
      await $folder->mkdir('foobar');
      await $folder->mkdir('foobarbaz');
      await $folder->mkdir('barbaz');
      await $folder->touch('sub/a');
      await $folder->touch('sub/b');
      await $folder->touch('sub/c');
    }

    $result = await $folder->find(re"/^foo([a-z\.])*/i");
    expect(C\count($result))->toBeSame(6);
    $result = await $folder->find(re"/^([a-z\.])*\.txt$/i", true);
    expect(C\count($result))->toBeSame(6);
    $result = await $folder->find(re"/.*/");
    expect(C\count($result))->toBeSame(13);
    $result = await $folder->find(re"/^([a-z\.])*\.baz.txt$/i");
    expect(C\count($result))->toBeSame(2);
    $result = await $folder->find(re"/.*bar.*/");
    expect(C\count($result))->toBeSame(8);
    $result = await $folder->find(re"/.*a(r|z).*/i", true);
    expect(C\count($result))->toBeSame(10);
    $result = await $folder->find(re"/.*a.*/");
    expect(C\count($result))->toBeSame(10);
    $result = await $folder->find(re"/.*a.*/", true);
    expect(C\count($result))->toBeSame(11);
  }

  <<DataProvider('provideMissingNodes')>>
  public function testFindThrowsIfFolderDoesntExist(
    Filesystem\Folder $folder,
  ): void {
    expect(async () ==> {
      expect($folder->exists())->toBeFalse();
      await $folder->find(re"/.*/");
    })->toThrow(Filesystem\Exception\MissingNodeException::class);
  }

  <<DataProvider('provideNodes')>>
  public async function testFindThrowsIfFolderIsUnreadable(
    Filesystem\Folder $folder,
  ): Awaitable<void> {
    $this->markAsSkippedIfRoot();
    $permissions = $folder->permissions();
    await $folder->chmod(0111);
    expect(() ==> $folder->find(re"/.*/"))
      ->toThrow(Filesystem\Exception\UnreadableNodeException::class);
    await $folder->chmod($permissions);
  }

  <<DataProvider('provideNodes')>>
  public async function testFolders(
    Filesystem\Folder $folder,
  ): Awaitable<void> {
    await $folder->flush();
    await $folder->mkdir('a/a/a');
    concurrent {
      await $folder->mkdir('b');
      await $folder->mkdir('c');
      await $folder->mkdir('a/b');
      await $folder->mkdir('a/c');
      await $folder->mkdir('a/a/b');
      await $folder->mkdir('a/a/c');
    }

    $folders = await $folder->folders(true, true);
    expect(C\count($folders))->toBeSame(9);
    expect($folders)->toBeSortedBy(
      (Filesystem\Node $a, Filesystem\Node $b) ==>
        $a->path()->compare($b->path()->toString()) < 0,
    );
    $folders = await $folder->folders(false, false);
    expect(C\count($folders))->toBeSame(3);
  }

  <<DataProvider('provideNodes')>>
  public async function testFiles(Filesystem\Folder $folder): Awaitable<void> {
    await $folder->flush();
    await $folder->mkdir('a/a/a');
    concurrent {
      await $folder->touch('a.txt');
      await $folder->touch('b.txt');
      await $folder->touch('c.txt');
      await $folder->touch('a/a.txt');
      await $folder->touch('a/b.txt');
      await $folder->touch('a/c.txt');
      await $folder->touch('a/a/a.txt');
      await $folder->touch('a/a/b.txt');
      await $folder->touch('a/a/c.txt');
    }

    $files = await $folder->files(true, true);
    expect(C\count($files))->toBeSame(9);
    expect($files)->toBeSortedBy(
      (Filesystem\Node $a, Filesystem\Node $b) ==>
        $a->path()->compare($b->path()->toString()) < 0,
    );
    $files = await $folder->files(false, false);
    expect(C\count($files))->toBeSame(3);
  }

  <<DataProvider('provideNodes')>>
  public async function testList(Filesystem\Folder $folder): Awaitable<void> {
    await $folder->flush();
    await $folder->mkdir('a/a/a');
    concurrent {
      await $folder->mkdir('b');
      await $folder->mkdir('c');
      await $folder->mkdir('a/b');
      await $folder->mkdir('a/c');
      await $folder->mkdir('a/a/b');
      await $folder->mkdir('a/a/c');
      await $folder->touch('a.txt');
      await $folder->touch('b.txt');
      await $folder->touch('c.txt');
      await $folder->touch('a/a.txt');
      await $folder->touch('a/b.txt');
      await $folder->touch('a/c.txt');
      await $folder->touch('a/a/a.txt');
      await $folder->touch('a/a/b.txt');
      await $folder->touch('a/a/c.txt');
    }

    $nodes = await $folder->list<Filesystem\Node>(true, true);
    expect(C\count($nodes))->toBeSame(18);
    expect($nodes)->toBeSortedBy(
      (Filesystem\Node $a, Filesystem\Node $b) ==>
        $a->path()->compare($b->path()->toString()) < 0,
    );
    $nodes = await $folder->list<Filesystem\Node>(false, false);
    expect(C\count($nodes))->toBeSame(6);
    $files = await $folder->list<Filesystem\File>(false, false);
    expect(C\count($files))->toBeSame(3);
    $files = await $folder->list<Filesystem\File>(true, true);
    expect(C\count($files))->toBeSame(9);
    $folders = await $folder->list<Filesystem\Folder>(false, false);
    expect(C\count($folders))->toBeSame(3);
    $folders = await $folder->list<Filesystem\Folder>(true, true);
    expect(C\count($folders))->toBeSame(9);
  }

  <<DataProvider('provideNodes')>>
  public async function testListThrowsIfFolderIsUnreadable(
    Filesystem\Folder $folder,
  ): Awaitable<void> {
    $this->markAsSkippedIfRoot();
    $permissions = $folder->permissions();
    await $folder->chmod(0111);
    expect(() ==> $folder->list<Filesystem\Node>())
      ->toThrow(Filesystem\Exception\UnreadableNodeException::class);
    await $folder->chmod($permissions);
  }

  <<DataProvider('provideMissingNodes')>>
  public function testListThrowsIfFolderDoesntExist(
    Filesystem\Folder $folder,
  ): void {
    expect(() ==> $folder->list<Filesystem\Node>())
      ->toThrow(Filesystem\Exception\MissingNodeException::class);
  }

  <<DataProvider('provideNodes')>>
  public async function testMove(Filesystem\Folder $folder): Awaitable<void> {
    $target = static::createPath();
    expect($target->exists())->toBeFalse();
    await $folder->move($target->toString(), false);
    expect($target->exists())->toBeTrue();
    expect($target->compare($folder->path()->toString()))->toBeSame(0);
  }

  <<DataProvider('provideExistingNodesPair')>>
  public async function testMoveOverride(
    Filesystem\Folder $folder,
    Filesystem\Folder $target,
  ): Awaitable<void> {
    $ret = await $folder->move($target->path()->toString(), true);
    expect($ret)->toBeTrue();
  }

  <<DataProvider('provideExistingNodesPair')>>
  public async function testMoveThrowsIfTargetExists(
    Filesystem\Folder $folder,
    Filesystem\Folder $target,
  ): Awaitable<void> {
    expect(() ==> $folder->move($target->path()->toString(), false))
      ->toThrow(Filesystem\Exception\ExistingNodeException::class);
  }

  <<DataProvider('provideMissingNodes')>>
  public async function testMoveThrowsIfFolderDoesntExist(
    Filesystem\Folder $folder,
  ): Awaitable<void> {
    expect(() ==> $folder->move('dummy'))->toThrow(
      Filesystem\Exception\MissingNodeException::class,
    );
  }

  <<DataProvider('provideNodes')>>
  public async function testSize(Filesystem\Folder $folder): Awaitable<void> {
    await $folder->flush();
    $size = await $folder->size();
    expect($size)->toBeSame(0);
    concurrent {
      await $folder->touch('a');
      await $folder->touch('b');
      await $folder->touch('c');
    }
    $size = await $folder->size();
    expect($size)->toBeSame(3);
  }

  <<DataProvider('provideMissingNodes')>>
  public function testSizeThrowsIfFolderDoesntExist(
    Filesystem\Folder $folder,
  ): void {
    expect(() ==> $folder->size())
      ->toThrow(Filesystem\Exception\MissingNodeException::class);
  }

  <<DataProvider('provideNodes')>>
  public async function testTouch(Filesystem\Folder $folder): Awaitable<void> {
    await $folder->flush();
    $size = await $folder->size();
    expect($size)->toBeSame(0);
    concurrent {
      await $folder->touch('foo');
      await $folder->touch('bar');
      await $folder->touch('baz');
    }
    $size = await $folder->size();
    expect($size)->toBeSame(3);
    $file = await $folder->touch('qux');
    expect($file->name())->toBeSame('qux');
    expect($file->parent()?->path()?->compare($folder->path()->toString()))
      ->toBeSame(0);
  }

  <<DataProvider('provideNodes')>>
  public async function testTouchMode(
    Filesystem\Folder $folder,
  ): Awaitable<void> {
    $this->markAsSkippedIfRoot();
    if ($folder->contains('foo')) {
      await $folder->remove('foo');
    }

    $file = await $folder->touch('foo', 0111);
    expect($file->readable())->toBeFalse();
    expect($file->writable())->toBeFalse();
    expect($file->executable())->toBeTrue();
    await $file->chmod(0755);

    if ($folder->contains('bar')) {
      await $folder->remove('bar');
    }

    $file = await $folder->touch('bar');
    expect($file->permissions())->toBeSame(0755);
    expect($file->readable())->toBeTrue();
    expect($file->writable())->toBeTrue();
    expect($file->executable())->toBeTrue();
  }

  <<DataProvider('provideNodes')>>
  public async function testTouchThrowsIfFolderIsUnwritable(
    Filesystem\Folder $folder,
  ): Awaitable<void> {
    if ($folder->contains('foo')) {
      await $folder->remove('foo');
    }
    $this->markAsSkippedIfRoot();
    $permissions = $folder->permissions();
    await $folder->chmod(0111);
    expect(() ==> $folder->touch('foo'))
      ->toThrow(Filesystem\Exception\UnwritableNodeException::class);
    await $folder->chmod($permissions);
  }

  <<DataProvider('provideNodes')>>
  public async function testTouchThrowsIfFileAlreadyExist(
    Filesystem\Folder $folder,
  ): Awaitable<void> {
    if (!$folder->contains('foo')) {
      await $folder->touch('foo');
    }

    expect(() ==> $folder->touch('foo'))
      ->toThrow(Filesystem\Exception\ExistingNodeException::class);
  }

  <<DataProvider('provideMissingNodes')>>
  public function testTouchThrowsIfFolderDoesntExist(
    Filesystem\Folder $folder,
  ): void {
    expect(() ==> $folder->touch('foo'))
      ->toThrow(Filesystem\Exception\MissingNodeException::class);
  }


  <<DataProvider('provideNodes')>>
  public async function testMkdir(Filesystem\Folder $folder): Awaitable<void> {
    await $folder->flush();
    $size = await $folder->size();
    expect($size)->toBeSame(0);
    concurrent {
      await $folder->mkdir('baz');
      await $folder->mkdir('bar');
      await $folder->mkdir('foo');
    }
    $size = await $folder->size();
    expect($size)->toBeSame(3);
    $child = await $folder->mkdir('qux');
    expect($child->name())->toBeSame('qux');
    expect($child->parent()?->path()?->compare($folder->path()->toString()))
      ->toBeSame(0);
  }

  <<DataProvider('provideNodes')>>
  public async function testMkdirMode(
    Filesystem\Folder $folder,
  ): Awaitable<void> {
    if ($folder->contains('foo')) {
      await $folder->remove('foo');
    }
    $this->markAsSkippedIfRoot();

    $child = await $folder->mkdir('foo', 0111);
    expect($child->readable())->toBeFalse();
    expect($child->writable())->toBeFalse();
    expect($child->executable())->toBeTrue();
    // clean up
    await $child->chmod(0755);

    if ($folder->contains('bar')) {
      await $folder->remove('bar');
    }

    $child = await $folder->mkdir('bar');
    expect($child->permissions())->toBeSame(0755);
    expect($child->readable())->toBeTrue();
    expect($child->writable())->toBeTrue();
    expect($child->executable())->toBeTrue();
  }

  <<DataProvider('provideNodes')>>
  public async function testMkdirThrowsIfFolderIsUnwritable(
    Filesystem\Folder $folder,
  ): Awaitable<void> {
    if ($folder->contains('foo')) {
      await $folder->remove('foo');
    }
    $this->markAsSkippedIfRoot();
    $permissions = $folder->permissions();
    await $folder->chmod(0111);
    expect(() ==> $folder->mkdir('foo'))
      ->toThrow(Filesystem\Exception\UnwritableNodeException::class);
    await $folder->chmod($permissions);
  }

  <<DataProvider('provideNodes')>>
  public async function testMkdirThrowsIfFileAlreadyExist(
    Filesystem\Folder $folder,
  ): Awaitable<void> {
    if (!$folder->contains('foo')) {
      await $folder->mkdir('foo');
    }

    expect(() ==> $folder->mkdir('foo'))
      ->toThrow(Filesystem\Exception\ExistingNodeException::class);
  }

  <<DataProvider('provideMissingNodes')>>
  public function testMkdirThrowsIfFolderDoesntExist(
    Filesystem\Folder $folder,
  ): void {
    expect(() ==> $folder->mkdir('foo'))
      ->toThrow(Filesystem\Exception\MissingNodeException::class);
  }

  <<DataProvider('provideNodes')>>
  public async function testRemove(Filesystem\Folder $folder): Awaitable<void> {
    await $folder->flush();
    concurrent {
      await $folder->touch('foo');
      await $folder->touch('bar');
      await $folder->touch('baz');
      await $folder->mkdir('foobar');
      await $folder->mkdir('barbaz');
      await $folder->mkdir('bazfoo');
    }
    $size = await $folder->size();
    expect($size)->toBeSame(6);

    await $folder->remove('foo');
    $size = await $folder->size();
    expect($size)->toBeSame(5);

    await $folder->remove('bar');
    $size = await $folder->size();
    expect($size)->toBeSame(4);

    await $folder->remove('baz');
    $size = await $folder->size();
    expect($size)->toBeSame(3);

    await $folder->remove('foobar');
    $size = await $folder->size();
    expect($size)->toBeSame(2);

    await $folder->remove('barbaz');
    $size = await $folder->size();
    expect($size)->toBeSame(1);

    await $folder->remove('bazfoo');
    $size = await $folder->size();
    expect($size)->toBeSame(0);
  }

  <<DataProvider('provideNodes')>>
  public async function testRemoveThrowsIfNodeDoesntExist(
    Filesystem\Folder $folder,
  ): Awaitable<void> {
    await $folder->flush();
    expect(() ==> $folder->remove('foo'))
      ->toThrow(Filesystem\Exception\MissingNodeException::class);
  }

  <<DataProvider('provideMissingNodes')>>
  public function testRemoveThrowsIfFolderDoesntExist(
    Filesystem\Folder $folder,
  ): void {
    expect(() ==> $folder->remove('foo'))
      ->toThrow(Filesystem\Exception\MissingNodeException::class);
  }

  <<DataProvider('provideNodes')>>
  public async function testContains(
    Filesystem\Folder $folder,
  ): Awaitable<void> {
    await $folder->flush();
    expect($folder->contains('foo'))->toBeFalse();
    await $folder->touch('foo');
    expect($folder->contains('foo'))->toBeTrue();
    expect($folder->contains('bar'))->toBeFalse();
    await $folder->mkdir('bar');
    expect($folder->contains('bar'))->toBeTrue();
    expect($folder->contains('baz'))->toBeFalse();
  }

  <<DataProvider('provideNodes')>>
  public async function testRead(Filesystem\Folder $folder): Awaitable<void> {
    await $folder->flush();
    await $folder->touch('foo');
    $foo = await $folder->read<Filesystem\File>('foo');
    expect($foo)->toBeInstanceOf(Filesystem\File::class);
    await $folder->mkdir('bar');
    $bar = await $folder->read<Filesystem\Folder>('bar');
    expect($bar)->toBeInstanceOf(Filesystem\Folder::class);

    expect(() ==> $folder->read<Filesystem\File>('bar'))
      ->toThrow(Filesystem\Exception\InvalidPathException::class);
    expect(() ==> $folder->read<Filesystem\Folder>('foo'))
      ->toThrow(Filesystem\Exception\InvalidPathException::class);
  }

  <<DataProvider('provideNodes')>>
  public async function testReadThrowsIfNodeDoesntExist(
    Filesystem\Folder $folder,
  ): Awaitable<void> {
    await $folder->flush();
    expect(() ==> $folder->read<Filesystem\Node>('foo'))
      ->toThrow(Filesystem\Exception\MissingNodeException::class);
  }

  <<DataProvider('provideMissingNodes')>>
  public function testReadThrowsIfFolderDoesntExist(
    Filesystem\Folder $folder,
  ): void {
    expect(() ==> $folder->read<Filesystem\Node>('foo'))
      ->toThrow(Filesystem\Exception\MissingNodeException::class);
  }

  <<DataProvider('provideNodes')>>
  public async function testChownRecursive(
    Filesystem\Folder $folder,
  ): Awaitable<void> {
    $this->markAsSkippedIfNotRoot();
    await $folder->flush();
    $nodes = vec[];
    concurrent {
      $nodes[] = await $folder->touch('foo');
      $nodes[] = await $folder->touch('bar');
      $nodes[] = await $folder->touch('baz');
      $nodes[] = await $folder->mkdir('foobar');
      $nodes[] = await $folder->mkdir('barbaz');
      $nodes[] = await $folder->mkdir('bazfoo');
    }
    await $folder->chown(655, true);
    expect($folder->owner())->toBeSame(655);
    foreach ($nodes as $node) {
      expect($node->owner())->toBeSame(655);
    }
  }

  <<DataProvider('provideNodes')>>
  public async function testChgroRecursive(
    Filesystem\Folder $folder,
  ): Awaitable<void> {
    $this->markAsSkippedIfNotRoot();
    await $folder->flush();
    $nodes = vec[];
    concurrent {
      $nodes[] = await $folder->touch('foo');
      $nodes[] = await $folder->touch('bar');
      $nodes[] = await $folder->touch('baz');
      $nodes[] = await $folder->mkdir('foobar');
      $nodes[] = await $folder->mkdir('barbaz');
      $nodes[] = await $folder->mkdir('bazfoo');
    }
    await $folder->chgrp(655, true);
    expect($folder->group())->toBeSame(655);
    foreach ($nodes as $node) {
      expect($node->group())->toBeSame(655);
    }
  }

  public async function provideNodes(
  ): Awaitable<Container<(Filesystem\Node)>> {
    $result = new \HH\Lib\Ref<vec<(Filesystem\Folder)>>(vec[]);
    $lastOperation = async {
    };
    for ($i = 0; $i < 3; $i++) {
      $lastOperation = async {
        await $lastOperation;
        $result->value[] = tuple(await static::createFolder());
        ;
      };
    }

    await $lastOperation;
    return $result->value;
  }

  public async function provideMissingNodes(
  ): Awaitable<Container<(Filesystem\Node)>> {
    return vec[
      tuple(new Filesystem\Folder(static::createPath()->toString())),
      tuple(new Filesystem\Folder(static::createPath()->toString())),
      tuple(new Filesystem\Folder(static::createPath()->toString())),
    ];
  }
}
