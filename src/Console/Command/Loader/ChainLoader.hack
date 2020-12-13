namespace Nuxed\Console\Command\Loader;

use namespace HH\Lib\{Str, Vec};
use namespace Nuxed\Console\{Command, Exception};

final class ChainLoader implements ILoader {
  private vec<ILoader> $loaders;

  public function __construct(ILoader ...$loaders) {
    $this->loaders = vec($loaders);
  }

  public function add(ILoader $loader): void {
    $this->loaders[] = $loader;
  }

  /**
   * Loads a command.
   */
  public function get(string $name): Command\Command {
    foreach ($this->loaders as $loader) {
      if ($loader->has($name)) {
        return $loader->get($name);
      }
    }

    throw new Exception\InvalidCommandException(
      Str\format('Command "%s" does not exists', $name),
    );
  }

  /**
   * Checks if a command exists.
   */
  public function has(string $name): bool {
    foreach ($this->loaders as $loader) {
      if ($loader->has($name)) {
        return true;
      }
    }

    return false;
  }

  /**
   * @return string[] All registered command names
   */
  public function getNames(): Container<string> {
    $names = vec[];
    foreach ($this->loaders as $loader) {
      $names = Vec\concat($names, $loader->getNames());
    }

    return $names;
  }
}
