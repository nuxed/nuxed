/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



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
