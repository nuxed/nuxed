namespace Nuxed\Cache\Store;

use namespace HH\Lib\Str;
use namespace Nuxed\Serializer;
use namespace Nuxed\Cache\Exception;

final class MCRouterStore implements IStore {
  use StoreTrait;

  public function __construct(
    private \MCRouter $mc,
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
    $ttl = $ttl ?? $this->defaultTtl;
    $value = $this->serializer->serialize<T>($value);
    if ($value is null) {
      return false;
    }

    if (0 >= $ttl) {
      await $this->mc->set($this->getId($id, $this->namespace), $value);
    } else {
      await $this->mc
        ->set($this->getId($id, $this->namespace), $value, 0, $ttl);
    }

    return true;
  }

  /**
   * Determines whether an item is present in the cache.
   */
  public async function contains(string $id): Awaitable<bool> {
    try {
      await $this->mc->get($this->getId($id, $this->namespace));
      return true;
    } catch (\MCRouterException $e) {
      return false;
    }
  }

  /**
   * Delete an item from the cache by its unique key.
   */
  public async function forget(string $id): Awaitable<bool> {
    if (!await $this->contains($id)) {
      return false;
    }

    await $this->mc->del($this->getId($id, $this->namespace));
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

    $value = await $this->mc->get($this->getId($id, $this->namespace));

    return $this->serializer->unserialize<T>($value);
  }

  public async function clear(): Awaitable<bool> {
    if (Str\is_empty($this->namespace)) {
      await $this->mc->flushAll();
      return true;
    }

    return false;
  }
}
