namespace Nuxed\Console\Input;

use namespace HH\Lib\IO;

/**
 * The `Input` class contains all available `Flag`, `Argument`, `Option`, and
 * `Command` objects available to parse given the provided input.
 */
interface IInput {
  /**
   * Add a new `Argument` candidate to be parsed from input.
   */
  public function addArgument(Definition\Argument $argument): this;

  /**
   * Add a new `Flag` candidate to be parsed from input.
   */
  public function addFlag(Definition\Flag $flag): this;

  /**
   * Add a new `Option` candidate to be parsed from input.
   */
  public function addOption(Definition\Option $option): this;

  /**
   * Parse and retrieve the active command name from the raw input.
   */
  public function getActiveCommand(): ?string;

  /**
   * Retrieve an `Argument` by its key or alias. Returns null if none exists.
   */
  public function getArgument(string $key): Definition\Argument;

  /**
   * Retrieve all `Argument` candidates.
   */
  public function getArguments(): Bag\ArgumentBag;

  /**
   * Retrieve a `Flag` by its key or alias. Returns null if none exists.
   */
  public function getFlag(string $key): Definition\Flag;

  /**
   * Retrieve all `Flag` candidates.
   */
  public function getFlags(): Bag\FlagBag;

  /**
   * Retrieve an `Option` by its key or alias. Returns null if none exists.
   */
  public function getOption(string $key): Definition\Option;

  /**
   * Retrieve all `Option` candidates.
   */
  public function getOptions(): Bag\OptionBag;

  /**
   * Return whether the input instance is running in `strict` mode or not.
   */
  public function getStrict(): bool;

  /**
   * Read in and return input from the user.
   */
  public function getUserInput(?int $length = null): Awaitable<string>;

  /**
   * Return the underlying `IO\ReadHandle` associated with this `Input` object.
   */
  public function getHandle(): IO\ReadHandle;

  /**
   * Parse input for all `Flag`, `Option`, and `Argument` candidates.
   */
  public function parse(bool $rewind = false): void;

  /**
   * Validate all `Flag`, `Option`, and `Argument` candidates.
   */
  public function validate(): void;

  /**
   * Set the arguments. This will override all existing arguments.
   */
  public function setArguments(Bag\ArgumentBag $arguments): this;

  /**
   * Set the flags. This will override all existing flags.
   */
  public function setFlags(Bag\FlagBag $flags): this;

  /**
   * Set the input to be parsed.
   */
  public function setInput(Container<string> $args): this;

  /**
   * Set the options. This will override all existing options.
   */
  public function setOptions(Bag\OptionBag $options): this;

  /**
   * Set the strict value.
   */
  public function setStrict(bool $strict): this;
}
