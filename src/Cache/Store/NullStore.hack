/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Cache\Store;

use namespace HH\Lib\Str;
use namespace Nuxed\Cache\Exception;

final class NullStore implements IStore {
  /**
   * Persists data in the cache, uniquely referenced by a key with an optional expiration TTL time.
   */
  public async function store<<<__Enforceable>> reify T>(
    string $_id,
    T $_value,
    ?int $_ttl = null,
  ): Awaitable<bool> {
    return false;
  }

  /**
   * Determines whether an item is present in the cache.
   */
  public async function contains(string $_id): Awaitable<bool> {
    return false;
  }

  /**
   * Delete an item from the cache by its unique key.
   */
  public async function forget(string $_id): Awaitable<bool> {
    return false;
  }

  /**
   * Fetches a value from the cache.
   */
  public async function get<<<__Enforceable>> reify T>(
    string $id,
  ): Awaitable<T> {
    throw new Exception\LogicException(
      Str\format('Item "%s" is not stored in cache.', $id),
    );
  }

  /**
   * Wipes clean the entire cache's keys.
   */
  public async function clear(): Awaitable<bool> {
    return false;
  }
}
