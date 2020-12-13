namespace Nuxed\Console\Input;

use namespace Nuxed\Console\Bag;

class AbstractBag<<<__Enforceable>> reify T as Definition\IDefinition>
  extends Bag\AbstractBag<string, T> {
  /**
   * Retrieve the definition object based on the given key.
   *
   * The key is checked against all available names as well as aliases.
   */
  <<__Override>>
  public function get(string $key, ?T $default = null): ?T {
    $value = parent::get($key, $default);
    if ($value is null) {
      foreach ($this as $definition) {
        if ($key === $definition->getAlias()) {
          return $definition;
        }
      }
    }

    return $value;
  }
}
