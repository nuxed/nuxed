namespace Nuxed\Cache\Store;

use namespace Nuxed\{Filesystem, Serializer};
use namespace HH\Lib\Str;
use namespace Nuxed\Cache\Exception;

final class FilesystemStore implements IStore {
  const FILE_SUFFIX = '.nuxed.cache';

  use StoreTrait;

  public function __construct(
    private Filesystem\Folder $folder,
    private Serializer\ISerializer $serializer,
    private string $namespace = '',
    private int $defaultTtl = 0,
  ) {}

  /**
   * Persists data in the cache, uniquely referenced by a key with an optional expiration TTL time.
   */
  public async function store<<<__Enforceable>> reify T>(
    string $id,
    T $value,
    ?int $ttl = null,
  ): Awaitable<bool> {
    if (!$this->folder->exists()) {
      await $this->folder->create();
    }

    $ttl = $ttl ?? $this->defaultTtl;

    $filename = $this->getFilename($id);
    $value = $this->serializer->serialize<(T, int)>(tuple($value, $ttl));
    if (null === $value) {
      return false;
    }

    if ($this->folder->contains($filename)) {
      $file = await $this->folder->read<Filesystem\File>($filename);
    } else {
      $file = await $this->folder->touch($filename);
    }

    await $file->write($value);

    return true;
  }

  /**
   * Determines whether an item is present in the cache.
   */
  public async function contains(string $id): Awaitable<bool> {
    $filename = $this->getFilename($id);
    if (!$this->folder->contains($filename)) {
      return false;
    }

    $time = \time();
    $file = await $this->folder->read<Filesystem\File>($filename);
    $content = await $file->read();
    list($_value, $expiry) = $this->serializer
      ->unserialize<(mixed, int)>($content);
    if (0 === $expiry) {
      return true;
    }

    $expiration_time = $file->modifyTime() + $expiry;
    $expired = $expiration_time <= $time;
    if ($expired) {
      await $file->delete();
      return false;
    }

    return true;
  }

  /**
   * Delete an item from the cache by its unique key.
   */
  public async function forget(string $id): Awaitable<bool> {
    if (!await $this->contains($id)) {
      return false;
    }

    $filename = $this->getFilename($id);
    $file = await $this->folder->read<Filesystem\File>($filename);
    await $file->delete();

    return true;
  }

  /**
   * Fetches a value from the cache.
   */
  public async function get<<<__Enforceable>> reify T>(
    string $id,
  ): Awaitable<T> {
    if (!await $this->contains($id)) {
      throw new Exception\LogicException(
        Str\format('Item "%s" is not stored in cache.', $id),
      );
    }

    $id = $this->getFilename($id);
    $file = await $this->folder->read<Filesystem\File>($id);
    $content = await $file->read();
    $cache = $this->serializer->unserialize<(T, int)>($content);

    return $cache[0];
  }

  /**
   * Wipes clean the entire cache's keys.
   */
  public async function clear(): Awaitable<bool> {
    if (Str\is_empty($this->namespace)) {
      await $this->folder->flush();
      return true;
    }

    if (!$this->folder->contains($this->namespace)) {
      return true;
    }

    $cache = await $this->folder->read<Filesystem\Folder>($this->namespace);
    await $cache->flush();
    return true;
  }

  protected function getFilename(string $id): string {
    return Str\format(
      '%s%s',
      $this->namespace === '' ? '' : Str\format('%s/', $this->namespace),
      \sha1($this->getId($id, $this->namespace)).static::FILE_SUFFIX,
    );
  }
}
