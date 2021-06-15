namespace Nuxed\Cache\Store;

use namespace HH\Lib\Str;
use namespace Nuxed\Serializer;
use namespace Nuxed\Cache\Exception;

final class ApcStore implements IStore {
  use StoreTrait;

  public function __construct(
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
    $id = $this->getId($id, $this->namespace);
    $ttl = $ttl ?? $this->defaultTtl;

    if (null === $value) {
      return false;
    }

    return \apc_store($id, $value, $ttl);
  }

  /**
   * Determines whether an item is present in the cache.
   */
  public async function contains(string $id): Awaitable<bool> {
    return \apc_exists($this->getId($id, $this->namespace));
  }

  /**
   * Delete an item from the cache by its unique key.
   */
  public async function forget(string $id): Awaitable<bool> {
    if (!await $this->contains($id)) {
      return false;
    }

    return \apc_delete($this->getId($id, $this->namespace));
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

    $success = false;
    $result = \apc_fetch($this->getId($id, $this->namespace), inout $success);
    if (!$success) {
      throw new Exception\RuntimeException(
        Str\format('Error fetching item "%s" from APC.', $id),
      );
    }

    return $result as T;
  }

  /**
   * Wipes clean the entire cache's keys.
   */
  public function clear(): Awaitable<bool> {
    if (Str\is_empty($this->namespace)) {
      return \apc_clear_cache();
    }

    /* HH_IGNORE_ERROR[2049] */
    $iterator = new \APCIterator(
      Str\format('/^%s/', \preg_quote($this->namespace, '/')),
      /* HH_IGNORE_ERROR[2049] */
      /* HH_IGNORE_ERROR[4106] */
      \APC_ITER_KEY,
    );

    return \apc_delete($iterator);
  }
}
