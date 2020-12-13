namespace Nuxed\Cache\Store;

interface IStore {
  /**
   * Persists data in the cache, uniquely referenced by a key with an optional expiration TTL time.
   */
  public function store<<<__Enforceable>> reify T>(
    string $id,
    T $value,
    ?int $ttl = null,
  ): Awaitable<bool>;

  /**
   * Determines whether an item is present in the cache.
   */
  public function contains(string $id): Awaitable<bool>;

  /**
   * Delete an item from the cache by its unique key.
   */
  public function forget(string $id): Awaitable<bool>;

  /**
   * Fetches a value from the cache.
   */
  public function get<<<__Enforceable>> reify T>(string $id): Awaitable<T>;

  /**
   * Wipes clean the entire cache's keys.
   */
  public function clear(): Awaitable<bool>;
}
