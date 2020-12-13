namespace Nuxed\Console\Input\Definition;

use namespace HH\Lib\Str;

/**
 * An `Option` is a value parameter specified by a user.
 */
final class Option extends AbstractDefinition<string> {
  /**
   * Construct a new `Option` object
   */
  public function __construct(
    string $name,
    string $description = '',
    Mode $mode = Mode::OPTIONAL,
    bool $aliased = true,
  ) {
    parent::__construct($name, $description, $mode);

    if ($aliased && Str\length($name) > 1) {
      $this->setAlias(Str\slice($name, 0, 1));
    }
  }
}
