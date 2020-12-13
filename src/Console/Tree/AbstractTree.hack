namespace Nuxed\Console\Tree;

/**
 * The `AbstractTree` class provides core functionality for building a tree given
 * a data structure.
 */
abstract class AbstractTree<Tk as arraykey, Tv> implements ITree<Tk, Tv> {
  protected dict<Tk, Tv> $data;

  /**
   * Construct a new instance of a tree.
   */
  public function __construct(KeyedContainer<Tk, Tv> $data = dict[]) {
    $this->data = dict<Tk, Tv>($data);
  }

  /**
   * Recursively build the tree and each branch and prepend necessary markup
   * for the output.
   */
  abstract protected function build(
    KeyedContainer<Tk, Tv> $tree,
    string $prefix = '',
  ): Awaitable<string>;

  /**
   * Retrieve the data of the tree.
   */
  public function getData(): KeyedContainer<Tk, Tv> {
    return $this->data;
  }

  /**
   * Render the tree.
   */
  public function render(): Awaitable<string> {
    return $this->build($this->data);
  }
}
