/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Cache\Store;

use namespace HH\Lib\{C, Str};
use namespace Nuxed\Cache\Exception;

final class MemoryStore implements IStore {
  use StoreTrait;

  private dict<string, (int, mixed)> $data = dict[];

  public function __construct(private int $defaultTtl = 0) {}

  /**
   * Persists data in the cache, uniquely referenced by a key with an optional expiration TTL time.
   */
  public async function store<<<__Enforceable>> reify T>(
    string $id,
    T $value,
    ?int $ttl = null,
  ): Awaitable<bool> {
    $id = $this->getId($id);
    $ttl = $ttl ?? $this->defaultTtl;

    $this->data[$id] = tuple(\time() + $ttl, $value);

    return true;
  }

  /**
   * Determines whether an item is present in the cache.
   */
  public async function contains(string $id): Awaitable<bool> {
    $id = $this->getId($id);
    if (!C\contains_key($this->data, $id)) {
      return false;
    }

    list($expiration_time, $_value) = $this->data[$id];
    if ($expiration_time > \time()) {
      return true;
    }

    unset($this->data[$id]);
    return false;
  }

  /**
   * Delete an item from the cache by its unique key.
   */
  public async function forget(string $id): Awaitable<bool> {
    if (!await $this->contains($id)) {
      return false;
    }

    unset($this->data[$this->getId($id)]);

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

    list($_ttl, $value) = $this->data[$this->getId($id)];

    return $value as T;
  }

  /**
   * Wipes clean the entire cache's keys.
   */
  public async function clear(): Awaitable<bool> {
    $this->data = dict[];

    return true;
  }
}
