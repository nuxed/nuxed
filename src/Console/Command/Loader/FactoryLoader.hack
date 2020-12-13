namespace Nuxed\Console\Command\Loader;

use namespace HH\Lib\{C, Str, Vec};
use namespace Nuxed\Console\{Command, Exception};

/**
 * A simple command loader using factories to instantiate commands lazily.
 */
final class FactoryLoader implements ILoader {
  private dict<string, (function(): Command\Command)> $factories;

  public function __construct(
    KeyedContainer<string, (function(): Command\Command)> $factories,
  ) {
    $this->factories = dict<string, (function(): Command\Command)>($factories);
  }

  /**
   * Loads a command.
   */
  public function get(string $name): Command\Command {
    if (!$this->has($name)) {
      throw new Exception\InvalidCommandException(
        Str\format('Command "%s" does not exists', $name),
      );
    }

    $factory = $this->factories[$name];
    return $factory();
  }

  /**
   * Checks if a command exists.
   */
  public function has(string $name): bool {
    return C\contains_key<string, string, (function(): Command\Command)>(
      $this->factories,
      $name,
    );
  }

  /**
   * @return string[] All registered command names
   */
  public function getNames(): Container<string> {
    return Vec\keys<string, (function(): Command\Command)>($this->factories);
  }
}
