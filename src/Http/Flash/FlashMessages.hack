/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http\Flash;

use namespace HH\Lib\{C, Str};
use namespace Nuxed\Http\{Exception, Session};
use namespace Facebook\TypeAssert;

final class FlashMessages implements IFlashMessages {
  const string FLASH_NEXT = self::class.'::FLASH_NEXT';

  const type TMessages = dict<string, shape(
    'value' => mixed,
    'hops' => int,
  )>;

  private dict<string, mixed> $current = dict[];

  public function __construct(
    private Session\ISession $session,
    private string $key,
  ) {
    $this->prepare();
  }

  /**
   * Create an instance from a session container.
   */
  public static function create(
    Session\ISession $session,
    string $sessionKey = self::FLASH_NEXT,
  ): this {
    return new FlashMessages($session, $sessionKey);
  }

  /**
   * Set a flash value with the given key.
   */
  public function flash<<<__Enforceable>> reify T>(
    string $key,
    T $value,
    int $hops = 1,
  ): void {
    if ($hops < 1) {
      throw new Exception\InvalidFlashHopsValueException(Str\format(
        'Hops value specified for flash message "%s" was too low; must be greater than 0, received %d',
        $key,
        $hops,
      ));
    }

    $messages = dict($this->messages());
    $messages[$key] = shape(
      'value' => $value,
      'hops' => $hops,
    );

    // dict<string, shape('value' => mixed, 'hops' => int)> is not
    // enforceable at runtime, use mixed instead.
    $this->session->put<mixed>($this->key, $messages);
  }

  /**
   * Set a flash value with the given key, but allow access during this request.
   */
  public function now<<<__Enforceable>> reify T>(
    string $key,
    T $value,
    int $hops = 1,
  ): void {
    $this->current[$key] = $value;
    $this->flash<T>($key, $value, $hops);
  }

  /**
   * Whether or not the container has the given key.
   */
  public function contains(string $key): bool {
    return C\contains_key($this->current, $key);
  }

  /**
   * Retrieve a flash value.
   */
  public function get<<<__Enforceable>> reify T>(string $key): T {
    invariant($this->contains($key), 'Invalid field key.');

    return $this->current[$key] as T;
  }

  /**
   * Retrieve all flash items.
   */
  public function items<<<__Enforceable>> reify T>(
  ): KeyedContainer<string, T> {
    $items = dict[];
    foreach ($items as $key => $value) {
      $items[$key] = $value as T;
    }

    return $items;
  }

  /**
   * Clear all flash values.
   */
  public function clear(): void {
    $this->session->forget($this->key);
  }

  /**
   * Prolongs any current flash messages for one more hop.
   */
  public function prolong(): void {
    $messages = $this->messages();
    foreach ($this->current as $key => $value) {
      if (C\contains_key($messages, $key)) {
        continue;
      }

      $this->flash<mixed>($key, $value);
    }
  }

  private function prepare(): void {
    if (!$this->session->contains($this->key)) {
      return;
    }

    $messages = $this->messages();
    $current = dict[];
    $next = dict[];

    foreach ($messages as $key => $data) {
      $current[$key] = $data['value'];

      if ($data['hops'] === 1) {
        continue;
      }

      $next[$key] = shape(
        'value' => $data['value'],
        'hops' => $data['hops'] - 1,
      );
    }

    if (C\is_empty($next)) {
      $this->session->forget($this->key);
    } else {
      $this->session->put<mixed>($this->key, $next);
    }

    $this->current = $current;
  }

  private function messages(): this::TMessages {
    if (!$this->session->contains($this->key)) {
      return dict[];
    }

    return TypeAssert\matches_type_structure(
      type_structure($this, 'TMessages'),
      // this::TMessages is not enforceable at runtime
      // so we need to use `mixed` and enforce the value
      // using TypeAssert.
      $this->session->get<mixed>($this->key),
    );
  }
}
