namespace Nuxed\Console\Bag;

use namespace HH\Lib\C;

/**
 * A bag can be used for managing sets of specialized data.
 */
abstract class AbstractBag<Tk as arraykey, Tv>
  implements \IteratorAggregate<Tv>, \Countable {
  protected dict<Tk, Tv> $data = dict[];

  /**
   * Set the parameters.
   */
  public function __construct(KeyedContainer<Tk, Tv> $data = dict[]) {
    $this->add($data);
  }

  /**
   * Add multiple parameters that will overwrite any previously defined parameters.
   */
  public function add(KeyedContainer<Tk, Tv> $data): this {
    foreach ($data as $key => $value) {
      $this->data[$key] = $value;
    }

    return $this;
  }

  /**
   * Return all parameters and their values within the bag.
   */
  public function all(): KeyedContainer<Tk, Tv> {
    return $this->data;
  }

  /**
   * Remove all values within the bag.
   */
  public function flush(): this {
    $this->data = dict[];

    return $this;
  }

  /**
   * Return a value defined by key, or by dot notated path.
   * If no key is found, return null, or if there is no value,
   * return the default value.
   */
  public function get(Tk $key, ?Tv $default = null): ?Tv {
    return $this->data[$key] ?? $default;
  }

  /**
   * Check if a key exists within the bag.
   * Can use a dot notated path as the key.
   */
  public function has(Tk $key): bool {
    return C\contains_key<Tk, Tk, Tv>($this->data, $key);
  }

  /**
   * Remove a value defined by key, or dot notated path.
   */
  public function remove(Tk $key): this {
    unset($this->data[$key]);

    return $this;
  }

  /**
   * Set a value defined by key. Can pass in a dot notated path
   * to insert into a nested structure.
   */
  public function set(Tk $key, Tv $value): this {
    return $this->add(dict[
      $key => $value,
    ]);
  }

  /**
   * Returns an iterator to be used to iterate over the object's elements.
   */
  public function getIterator(): KeyedIterator<Tk, Tv> {
    return new Map<Tk, Tv>($this->data) |> $$->getIterator();
  }

  public function count(): int {
    return C\count($this->data);
  }
}
