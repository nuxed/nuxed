/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Cache;

interface ICache {
  /**
   * Determine if an item exists in the cache.
   */
  public function contains(string $key): Awaitable<bool>;

  /**
   * Fetches a value from the cache.
   */
  public function get<<<__Enforceable>> reify T>(string $key): Awaitable<T>;

  /**
   * Retrieve a value from the cache and delete it.
   */
  public function pull<<<__Enforceable>> reify T>(string $key): Awaitable<T>;

  /**
   * Store an item in the cache.
   */
  public function put<<<__Enforceable>> reify T>(
    string $key,
    T $value,
    ?int $ttl = null,
  ): Awaitable<bool>;

  /**
   * Store an item in the cache if the key does not exist.
   */
  public function add<<<__Enforceable>> reify T>(
    string $key,
    T $value,
    ?int $ttl = null,
  ): Awaitable<bool>;

  /**
   * Get an item from the cache, or execute the given Closure and store the result.
   */
  public function remember<<<__Enforceable>> reify T>(
    string $key,
    (function(): Awaitable<T>) $callback,
    ?int $ttl = null,
  ): Awaitable<T>;

  /**
   * Remove an item from the cache.
   */
  public function forget(string $key): Awaitable<bool>;

  /**
   * Wipes clean the entire cache's keys.
   */
  public function clear(): Awaitable<bool>;
}
