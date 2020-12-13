namespace Nuxed\Http\Flash;

use namespace Nuxed\Http\Session;

interface IFlashMessages {
  /**
   * Create an instance from a session container.
   */
  public static function create(Session\ISession $session): this;

  /**
   * Set a flash value with the given key.
   */
  public function flash<<<__Enforceable>> reify T>(
    string $key,
    T $value,
    int $hops = 1,
  ): void;

  /**
   * Set a flash value with the given key, but allow access during this request.
   */
  public function now<<<__Enforceable>> reify T>(
    string $key,
    T $value,
    int $hops = 1,
  ): void;

  /**
   * Whether or not the container has the given key.
   */
  public function contains(string $key): bool;

  /**
  * Retrieve a flash value.
  */
  public function get<<<__Enforceable>> reify T>(string $name): T;

  /**
   * Retrieve all flash items.
   */
  public function items<<<__Enforceable>> reify T>(): KeyedContainer<string, T>;

  /**
   * Clear all flash values.
   */
  public function clear(): void;

  /**
   * Prolongs any current flash messages for one more hop.
   */
  public function prolong(): void;
}
