/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Console\Input\Definition;

use namespace HH\Lib\Str;

/**
 * An Definition is an object that designates the parameters accepted by
 * the user when executing commands.
 */
abstract class AbstractDefinition<<<__Enforceable>> reify T>
  implements IDefinition {
  /**
   * An alternate notation to specify the input as.
   */
  protected string $alias = '';

  /**
   * The description of the input.
   */
  protected string $description;

  /**
   * Flag if the `Definition` has been assigned a value.
   */
  protected bool $exists = false;

  /**
   * The mode of the input to determine if it should be required by the user.
   */
  protected Mode $mode;

  /**
   * The name and primary method to specify the input.
   */
  protected string $name;

  /**
   * The value the user has given the input.
   */
  protected ?T $value;

  /**
   * Cosntruct a new instance of an `Definition`.
   */
  public function __construct(
    string $name,
    string $description = '',
    Mode $mode = Mode::OPTIONAL,
  ) {
    $this->name = $name;
    $this->description = $description;
    $this->mode = $mode;
  }

  /**
   * Alias method for setting the alias of the `Definition`.
   *
   * @param string $alias The input's alias
   *
   * @return $this
   */
  public function alias(string $alias): this {
    return $this->setAlias($alias);
  }

  /**
   * {@inheritdoc}
   */
  public function exists(): bool {
    return $this->exists;
  }

  /**
   * Retrieve the alias of the `Definition`.
   */
  public function getAlias(): string {
    return $this->alias;
  }

  /**
   * Retrieve the description of the `Definition`.
   */
  public function getDescription(): string {
    return $this->description;
  }

  /**
   * Retrieve the formatted name as it should be entered by the user.
   */
  public function getFormattedName(string $name): string {
    if (Str\length($name) === 1) {
      return '-'.$name;
    }

    return '--'.$name;
  }

  /**
   * Retrieve the mode of the `Definition`.
   */
  public function getMode(): Mode {
    return $this->mode;
  }

  /**
   * Retrieve the name of the `Definition`.
   */
  public function getName(): string {
    return $this->name;
  }

  /**
   * Retrieve the value as specified by the user for the `Definition`. If
   * the user has not specified the value, the default value is returned.
   */
  public function getValue(?T $default = null): ?T {
    if ($this->value is nonnull) {
      return $this->value as T;
    }

    return $default;
  }

  /**
   * Set the alias of the `Definition`.
   */
  public function setAlias(string $alias): this {
    if (Str\length($alias) > Str\length($this->name)) {
      $this->alias = $this->name;
      $this->name = $alias;
    } else {
      $this->alias = $alias;
    }

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  public function setExists(bool $exists): this {
    $this->exists = $exists;

    return $this;
  }

  /**
   * Set the value of the `Definition`.
   */
  public function setValue(T $value): this {
    $this->value = $value;

    return $this;
  }
}
