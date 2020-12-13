namespace Nuxed\Console\Command\Manager;

use namespace HH;
use namespace Nuxed\Console\{Command, Exception, Output, _Private};
use namespace HH\Lib\{C, Dict, Str, Vec};

final class Manager implements IManager {
  /**
   * The `Loader` instance to use to lookup commands.
   */
  private Command\Loader\ChainLoader $loader;

  /**
   * Store added commands until we inject them into the `Input` at runtime.
   */
  private dict<string, Command\Command> $commands = dict[];

  public function __construct() {
    $this->loader = new Command\Loader\ChainLoader();
  }

  /**
   * Add a `CommandLoader` to use for command discovery.
   */
  public function addLoader(Command\Loader\ILoader $loader): this {
    foreach ($loader->getNames() as $name) {
      _Private\validate_command_name($name);
    }

    $this->loader->add($loader);

    return $this;
  }

  /**
   * Add a `Command` to the application to be parsed by the `Input`.
   */
  public function add(Command\Command $command): this {
    if (!$command->isEnabled()) {
      return $this;
    }

    _Private\validate_command_name($command->getName());
    foreach ($command->getAliases() as $alias) {
      _Private\validate_command_name($alias);
    }

    $this->commands[$command->getName()] = $command;

    return $this;
  }

  /**
   * Returns true if the command exists, false otherwise.
   */
  public function has(string $name): bool {
    return C\contains_key<string, string, Command\Command>(
      $this->commands,
      $name,
    ) ||
      $this->loader->has($name);
  }

  /**
   * Returns a registered command by name or alias.
   */
  public function get(string $name): Command\Command {
    if (!$this->has($name)) {
      throw new Exception\CommandNotFoundException(
        Str\format('The command "%s" does not exist.', $name),
      );
    }

    $command = $this->commands[$name] ?? null;
    if ($command is null) {
      $command = $this->loader->get($name);
    }

    return $command;
  }

  /**
   * Finds a command by name or alias.
   *
   * Contrary to get, this command tries to find the best
   * match if you give it an abbreviation of a name or alias.
   */
  public function find(string $name): Command\Command {
    foreach ($this->commands as $command) {
      foreach ($command->getAliases() as $alias) {
        if (!$this->has($alias)) {
          $this->commands[$alias] = $command;
        }
      }
    }

    if ($this->has($name)) {
      return $this->get($name);
    }

    $allCommands = Vec\concat<string>(
      $this->loader->getNames(),
      Vec\keys<string, Command\Command>($this->commands),
    );

    $message = Str\format('Command "%s" is not defined.', $name);
    $alternatives = $this->findAlternatives($name, $allCommands);
    if (!C\is_empty<string>($alternatives)) {
      // remove hidden commands
      $alternatives = Vec\filter<string>(
        $alternatives,
        (string $name): bool ==> !$this->get($name)->isHidden(),
      );
      if (1 === C\count($alternatives)) {
        $message .= Str\format(
          '%s%sDid you mean this?%s%s',
          Output\IOutput::EndOfLine,
          Output\IOutput::EndOfLine,
          Output\IOutput::EndOfLine,
          Output\IOutput::EndOfLine,
        );
      } else {
        $message .= Str\format(
          '%s%sDid you mean one of these?%s%s',
          Output\IOutput::EndOfLine,
          Output\IOutput::EndOfLine,
          Output\IOutput::EndOfLine,
          Output\IOutput::EndOfLine,
        );
      }

      foreach ($alternatives as $alternative) {
        $message .= Str\format(
          '    - %s%s',
          $alternative,
          Output\IOutput::EndOfLine,
        );
      }
    }

    throw new Exception\CommandNotFoundException($message);
  }

  /**
   * Gets the commands.
   *
   * The container keys are the full names and the values the command instances.
  */
  public function all(): KeyedContainer<string, Command\Command> {
    $commands = $this->commands;
    foreach ($this->loader->getNames() as $name) {
      if (
        !C\contains_key<string, string, Command\Command>($commands, $name) &&
        $this->has($name)
      ) {
        $commands[$name] = $this->get($name);
      }
    }

    return $commands;
  }


  /**
   * Finds alternative of $name among $collection.
   */
  private function findAlternatives(
    string $name,
    Container<string> $collection,
  ): Container<string> {
    $threshold = 1e3;
    $alternatives = dict[];
    $collectionParts = dict[];
    foreach ($collection as $item) {
      $collectionParts[$item] = Str\split($item, ':');
    }

    foreach (Str\split($name, ':') as $i => $subname) {
      foreach ($collectionParts as $collectionName => $parts) {
        $exists = C\contains_key<string, string, num>(
          $alternatives,
          $collectionName,
        );
        if (!C\contains_key<int, int, string>($parts, $i)) {
          if ($exists) {
            $alternatives[$collectionName] += $threshold;
          }

          continue;
        }

        $lev = \levenshtein($subname, $parts[$i]) as num;
        if (
          $lev <= Str\length($subname) / 3 ||
          '' !== $subname && Str\contains($parts[$i], $subname)
        ) {
          $alternatives[$collectionName] = $exists
            ? $alternatives[$collectionName] + $lev
            : $lev;
        } else if ($exists) {
          $alternatives[$collectionName] += $threshold;
        }
      }
    }

    foreach ($collection as $item) {
      $lev = \levenshtein($name, $item) as num;
      if ($lev <= Str\length($name) / 3 || Str\contains($item, $name)) {
        $alternatives[$item] = C\contains_key<string, string, num>(
          $alternatives,
          $item,
        )
          ? $alternatives[$item] - $lev
          : $lev;
      }
    }

    return Dict\filter<string, num>(
      $alternatives,
      (num $lev): bool ==> $lev < (2 * $threshold),
    )
      |> Dict\sort<string, num>($$)
      |> Vec\keys<string, num>($$);
  }
}
