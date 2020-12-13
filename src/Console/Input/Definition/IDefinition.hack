namespace Nuxed\Console\Input\Definition;

/**
 * An `IDefinition` defines the name and type of input that may be accepted
 * by the user.
 */
interface IDefinition {
  /**
   * Returns if the `IDefinition` has been assigned a value by the parser.
   */
  public function exists(): bool;

  /**
   * Retrieve the alias of the `IDefinition`.
   */
  public function getAlias(): string;

  /**
   * Retrieve the description of the `IDefinition`.
   */
  public function getDescription(): string;

  /**
   * Retrieve the formatted name suitable for output in a help screen or
   * documentation.
   */
  public function getFormattedName(string $name): string;

  /**
   * Retrieve the mode of the `IDefinition`.
   */
  public function getMode(): Mode;

  /**
   * Retrieve the name of the `IDefinition`.
   */
  public function getName(): string;

  /**
   * Retrieve the value of the `IDefinition` as specified by the user.
   */
  public function getValue<<<__Enforceable>> reify T>(?T $default = null): ?T;

  /**
   * Set if the `IDefinition` has been assigned a value.
   */
  public function setExists(bool $exists): this;
}
