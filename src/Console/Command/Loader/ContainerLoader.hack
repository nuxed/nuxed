namespace Nuxed\Console\Command\Loader;

use namespace Nuxed\Console\{Command, Exception};
use namespace Nuxed\DependencyInjection;
use namespace HH\Lib\{C, Dict, Str, Vec};

final class ContainerLoader implements ILoader {
  private dict<string, Command\Command> $commands = dict[];

  public function __construct(
    private DependencyInjection\IServiceContainer $container,
  ) {
    $commands = $container->tagged<Command\Command>(Command\Command::class);

    $entries = Vec\map($commands, ($command) ==> {
      return tuple($command->getName(), $command);
    });

    $this->commands = Dict\from_entries($entries);
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

    return $this->commands[$name];
  }

  /**
   * Checks if a command exists.
   */
  public function has(string $name): bool {
    return C\contains_key($this->commands, $name);
  }

  /**
   * @return string[] All registered command names
   */
  public function getNames(): Container<string> {
    $commands = $this->container
      ->tagged<Command\Command>(Command\Command::class);

    $names = vec[];
    foreach ($commands as $command) {
      $names[] = $command->getName();
    }

    return $names;
  }
}
