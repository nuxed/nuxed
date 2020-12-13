namespace Nuxed\Console\Input\Definition;

/**
 * An `Argument` is a parameter specified by the user that does not use any
 * notation (i.e., --foo, -f).
 */
final class Argument extends AbstractDefinition<string> {
  /**
   * {@inheritdoc}
   */
  <<__Override>>
  public function getFormattedName(string $name): string {
    return $name;
  }
}
