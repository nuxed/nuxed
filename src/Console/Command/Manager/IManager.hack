namespace Nuxed\Console\Command\Manager;

use namespace Nuxed\Console\Command;

interface IManager {
  /**
   * Add a `ILoader` to use for command discovery.
   */
  public function addLoader(Command\Loader\ILoader $loader): this;

  /**
   * Add a `Command` to the manager..
   */
  public function add(Command\Command $command): this;

  /**
   * Returns true if the command exists, false otherwise.
   */
  public function has(string $name): bool;

  /**
   * Returns a registered command by name or alias.
   */
  public function get(string $name): Command\Command;

  /**
   * Finds a command by name or alias.
   *
   * Contrary to get, this command tries to find the best
   * match if you give it an abbreviation of a name or alias.
   */
  public function find(string $name): Command\Command;

  /**
   * Gets the commands.
   *
   * The container keys are the full names and the values the command instances.
  */
  public function all(): KeyedContainer<string, Command\Command>;
}
