namespace Nuxed\Console\Tree;

/**
 * A `ITree` object will construct the markup for a human readable of nested data.
 */
interface ITree<Tk as arraykey, Tv> {
  /**
   * Retrieve the data structure of the `ITree`.
   */
  public function getData(): KeyedContainer<Tk, Tv>;

  /**
   * Build and return the markup for the `ITree`.
   */
  public function render(): Awaitable<string>;
}
