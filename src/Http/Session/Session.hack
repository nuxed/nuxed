/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http\Session;

use namespace HH\Lib\{C, Dict};

final class Session implements ISession {
  const string SESSION_AGE_KEY = '__SESSION_AGE__';

  /**
   * Current data within the session.
   */
  private dict<string, mixed> $data;

  private bool $isRegenerated = false;

  private dict<string, mixed> $originalData;

  /**
   * Lifetime of the session cookie.
   */
  private int $age = 0;

  private bool $flushed = false;

  public function __construct(
    KeyedContainer<string, mixed> $data,
    private string $id = '',
  ) {
    $this->data = dict<string, mixed>($data);
    $this->originalData = $this->data;

    if (C\contains_key($this->data, Session::SESSION_AGE_KEY)) {
      $this->age = $this->data[Session::SESSION_AGE_KEY] as int;
    }
  }

  /**
   * Retrieve the session identifier.
   */
  public function getId(): string {
    return $this->id;
  }

  /**
   * Retrieve a value from the session.
   */
  public function get<<<__Enforceable>> reify T>(string $key): T {
    invariant($this->contains($key), 'Invalid field name.');

    return $this->data[$key] as T;
  }

  /**
   * Whether or not the container has the given key.
   */
  public function contains(string $key): bool {
    return C\contains_key($this->data, $key);
  }

  /**
   * Store a value in the session.
   *
   * Values MUST be serializable in any format; we recommend ensuring the
   * values are JSON serializable for greatest portability.
   */
  public function put<<<__Enforceable>> reify T>(string $key, T $value): void {
    $this->data[$key] = $value;
  }

  /**
   * Store a value in the session if the key does not exist.
   */
  public function add<<<__Enforceable>> reify T>(string $key, T $value): void {
    if (!$this->contains($key)) {
      $this->put<T>($key, $value);
    }
  }

  /**
   * Get an item from the session, or execute the given Closure and store the result.
   */
  public function remember<<<__Enforceable>> reify T>(
    string $key,
    (function(): T) $factory,
  ): T {
    if (!$this->contains($key)) {
      $this->put<T>($key, $factory());
    }

    return $this->get<T>($key);
  }

  /**
   * Remove a value from the session.
   */
  public function forget(string $key): void {
    $this->data = Dict\filter_with_key(
      $this->data,
      ($k, $_v): bool ==> $key !== $k,
    );
  }

  /**
   * Clear all values.
   */
  public function clear(): void {
    $this->data = dict[];
  }

  /**
   * Deletes the current session data from the session and
   * deletes the session cookie. This is used if you want to ensure
   * that the previous session data can't be accessed again from the
   * user's browser.
   */
  public function flush(): void {
    $this->clear();
    $this->flushed = true;
  }

  public function flushed(): bool {
    return $this->flushed;
  }

  /**
   * Does the session contain changes? If not, the middleware handling
   * session persistence may not need to do more work.
   */
  public function changed(): bool {
    if ($this->regenerated()) {
      return true;
    }

    return $this->data !== $this->originalData;
  }

  /**
   * Regenerate the session.
   *
   * This can be done to prevent session fixation. When executed, it SHOULD
   * return a new instance; that instance should always return true for
   * isRegenerated().
   */
  public function regenerate(): this {
    $session = clone $this;
    $session->isRegenerated = true;
    return $session;
  }

  /**
   * Method to determine if the session was regenerated; should return
   * true if the instance was produced via regenerate().
   */
  public function regenerated(): bool {
    return $this->isRegenerated;
  }

  /**
   * Sets the expiration time for the session.
   *
   * The session will expire after that many seconds
   * of inactivity.
   *
   * for example, calling
   * <code>
   *     $session->expire(300);
   * </code>
   * would make the session expire in 5 minutes of inactivity.
   */
  public function expire(int $duration): void {
    $this->put<int>(Session::SESSION_AGE_KEY, $duration);
    $this->age = $duration;
  }

  /*
   * Determine how long the session cookie should live.
   *
   * Generally, this will return the value provided to expire().
   *
   * If that method has not been called, the value can return one of the
   * following:
   *
   * - 0 or a negative value, to indicate the cookie should be treated as a
   *   session cookie, and expire when the window is closed. This should be
   *   the default behavior.
   * - If expire() was provided during session creation or anytime later,
   *   the persistence engine should pull the TTL value from the session itself
   *   and return it here.
   */
  public function age(): int {
    return $this->age;
  }

  /**
   * Retrieve all session items.
   */
  public function items<<<__Enforceable>> reify T>(
  ): KeyedContainer<string, T> {
    $items = dict[];
    foreach ($this->data as $key => $value) {
      $items[$key] = $value as T;
    }

    return $items;
  }
}
