/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Cache;

final class Cache implements ICache {

  public function __construct(protected Store\IStore $store) {
  }

  /**
   * Determine if an item exists in the cache.
   */
  public async function contains(string $key): Awaitable<bool> {
    return await $this->box(async () ==> await $this->store->contains($key));
  }

  /**
   * Fetches a value from the cache.
   */
  public async function get<<<__Enforceable>> reify T>(
    string $key,
  ): Awaitable<T> {
    return await $this->box(async () ==> await $this->store->get<T>($key));
  }

  /**
   * Retrieve a value from the cache and delete it.
   */
  public async function pull<<<__Enforceable>> reify T>(
    string $key,
  ): Awaitable<T> {
    $value = await $this->get<T>($key);
    await $this->forget($key);
    return $value;
  }

  /**
   * Store an item in the cache.
   */
  public async function put<<<__Enforceable>> reify T>(
    string $key,
    T $value,
    ?int $ttl = null,
  ): Awaitable<bool> {
    return await $this->box(
      async () ==> await $this->store->store<T>($key, $value, $ttl),
    );
  }

  /**
   * Store an item in the cache if the key does not exist.
   */
  public async function add<<<__Enforceable>> reify T>(
    string $key,
    T $value,
    ?int $ttl = null,
  ): Awaitable<bool> {
    if (await $this->contains($key)) {
      return false;
    }

    return await $this->put<T>($key, $value, $ttl);
  }

  /**
   * Get an item from the cache, or execute the given Closure and store the result.
   */
  public async function remember<<<__Enforceable>> reify T>(
    string $key,
    (function(): Awaitable<T>) $callback,
    ?int $ttl = null,
  ): Awaitable<T> {
    if (await $this->contains($key)) {
      return await $this->get<T>($key);
    }

    $value = await $callback();
    await $this->put<T>($key, $value, $ttl);
    return $value;
  }

  /**
   * Remove an item from the cache.
   */
  public async function forget(string $key): Awaitable<bool> {
    return await $this->box(async () ==> await $this->store->forget($key));
  }

  /**
   * Wipes clean the entire cache's keys.
   */
  public async function clear(): Awaitable<bool> {
    return await $this->box(async () ==> await $this->store->clear());
  }

  protected async function box<T>(
    (function(): Awaitable<T>) $fun,
  ): Awaitable<T> {
    try {
      return await $fun();
    } catch (\Exception $e) {
      if (!$e is Exception\IException) {
        $e = new Exception\RuntimeException(
          $e->getMessage(),
          $e->getCode(),
          $e,
        );
      }

      throw $e;
    }
  }
}
