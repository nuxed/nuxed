/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Console\Command;

use namespace Nuxed\Console;
use namespace Nuxed\Console\{Input, Output};
use namespace Nuxed\Console\Input\{Bag, Definition};

/**
 * A `Command` is a class that configures necessary command line inputs from the
 * user and executes its `run` method when called.
 */
abstract class Command {
  /**
   * The name of the command passed into the command line.
   */
  protected string $name = '';

  /**
   * The aliases for the command name.
   */
  protected Container<string> $aliases = vec[];

  /**
   * The description of the command used when rendering its help screen.
   */
  protected string $description = '';

  protected bool $hidden = false;

  /**
   * Bag container holding all registered `Argument` objects
   */
  protected Bag\ArgumentBag $arguments;

  /**
   * Bag container holding all registered `Flag` objects
   */
  protected Bag\FlagBag $flags;

  /**
   * Bag container holding all registered `Option` objects
   */
  protected Bag\OptionBag $options;

  /**
   * The `Input` object containing all registered and parsed command line
   * parameters.
   */
  <<__LateInit>> protected Input\IInput $input;

  /**
   * The `Output` object to handle output to the user.
   */
  <<__LateInit>> protected Output\IOutput $output;

  /**
   * The `Application` that is currently running the command.
   */
  <<__LateInit>> protected Console\Application $application;

  /**
   * Construct a new instance of a command.
   */
  public function __construct(string $name = '') {
    $this->arguments = new Bag\ArgumentBag();
    $this->flags = new Bag\FlagBag();
    $this->options = new Bag\OptionBag();
    if ('' !== $name) {
      $this->setName($name);
    }

    $this->configure();
  }

  /**
   * The configure method that sets up name, description, and necessary parameters
   * for the `Command` to run.
   */
  abstract public function configure(): void;

  /**
   * The method that stores the code to be executed when the `Command` is run.
   */
  abstract public function run(): Awaitable<int>;

  /**
   * {@inheritdoc}
   */
  public function registerInput(): this {
    $arguments = (new Bag\ArgumentBag())->add($this->arguments->all());
    foreach (
      $this->input->getArguments()->getIterator() as $name => $argument
    ) {
      $arguments->set($name, $argument);
    }
    $this->input->setArguments($arguments);

    $flags = (new Bag\FlagBag())->add($this->flags->all());
    foreach ($this->input->getFlags()->getIterator() as $name => $flag) {
      $flags->set($name, $flag);
    }
    $this->input->setFlags($flags);

    $options = (new Bag\OptionBag())->add($this->options->all());
    foreach ($this->input->getOptions()->getIterator() as $name => $option) {
      $options->set($name, $option);
    }
    $this->input->setOptions($options);

    return $this;
  }

  /**
   * Set the command's description.
   */
  public function setDescription(string $description): this {
    $this->description = $description;

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  public function setInput(Input\IInput $input): this {
    $this->input = $input;

    return $this;
  }

  /**
   * Set the command's name.
   */
  public function setName(string $name): this {
    $this->name = $name;

    return $this;
  }

  /**
   * Sets the aliases for the command.
   */
  public function setAliases(Container<string> $aliases): this {
    $this->aliases = $aliases;
    return $this;
  }

  /**
   * {@inheritdoc}
   */
  public function setOutput(Output\IOutput $output): this {
    $this->output = $output;

    return $this;
  }

  public function setApplication(Console\Application $application): this {
    $this->application = $application;

    return $this;
  }

  /**
   * Add a new `Argument` to be registered and parsed with the `Input`.
   */
  public function addArgument(Definition\Argument $argument): this {
    $this->arguments->set($argument->getName(), $argument);

    return $this;
  }

  /**
   * Add a new `Flag` to be registered and parsed with the `Input`.
   */
  public function addFlag(Definition\Flag $flag): this {
    $this->flags->set($flag->getName(), $flag);

    return $this;
  }

  /**
   * Add a new `Option` to be registered and parsed with the `Input`.
   */
  public function addOption(Definition\Option $option): this {
    $this->options->set($option->getName(), $option);

    return $this;
  }

  /**
   * Whether or not the command should be hidden from the list of commands
   */
  public function setHidden(bool $hidden): this {
    $this->hidden = $hidden;
    return $this;
  }

  /**
   * Checks whether the command is enabled or not in the current environment.
   *
   * Override this to check for x or y and return false if the command can not
   * run properly under the current conditions.
   */
  public function isEnabled(): bool {
    return true;
  }

  /**
   * Checks whether the command should be publicly shown or not
   */
  public function isHidden(): bool {
    return $this->hidden;
  }

  /**
   * Retrieve an `Argument` value by key.
   */
  protected function getArgument(
    string $key,
    ?string $default = null,
  ): ?string {
    return $this->input->getArgument($key)->getValue($default);
  }

  /**
   * Retrieve all `Argument` objects registered specifically to this command.
   */
  public function getArguments(): Bag\ArgumentBag {
    return $this->arguments;
  }

  /**
   * Retrieve the command's description.
   */
  public function getDescription(): string {
    return $this->description;
  }

  /**
   * Retrieve a `Flag` value by key.
   */
  protected function getFlag(string $key, ?int $default = null): ?int {
    return $this->input->getFlag($key)->getValue($default);
  }

  /**
   * Retrieve all `Flag` objects registered specifically to this command.
   */
  public function getFlags(): Bag\FlagBag {
    return $this->flags;
  }

  /**
   * Retrieve the command's name.
   */
  public function getName(): string {
    return $this->name;
  }

  /**
   * Retrieve an `Option` value by key.
   */
  protected function getOption(string $key, ?string $default = null): ?string {
    return $this->input->getOption($key)->getValue($default);
  }

  /**
   * Retrieve all `Option` objects registered specifically to this command.
   */
  public function getOptions(): Bag\OptionBag {
    return $this->options;
  }

  /**
   * Returns the aliases for the command.
   */
  public function getAliases(): Container<string> {
    return $this->aliases;
  }

  public function getApplication(): Console\Application {
    return $this->application;
  }
}
