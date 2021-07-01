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
 * A `Flag` is a boolean parameter (denoted by an integer) specified by a user.
 */
final class Flag extends AbstractDefinition<int> {
  /**
   * The negative alias of the `Flag` (i.e., --no-foo for -foo). A negative
   * value is only available if a 'long' `Flag` name is available.
   */
  protected string $negativeAlias = '';

  /**
   * Whether the flag is stackable or not (i.e., -fff is given a value of 3).
   */
  protected bool $stackable = false;

  /**
   * Construct a new `Flag` object
   */
  public function __construct(
    string $name,
    string $description = '',
    Mode $mode = Mode::OPTIONAL,
    bool $stackable = false,
  ) {
    parent::__construct($name, $description, $mode);

    if (Str\length($name) > 1) {
      $this->negativeAlias = 'no-'.$name;
    }

    $this->stackable = $stackable;
  }

  /**
   * Retrieve the negative alias of the `Flag` or null of none.
   */
  public function getNegativeAlias(): string {
    return $this->negativeAlias;
  }

  /**
   * If the `Flag` is stackable, increase its value for each occurrence of the
   * flag.
   */
  public function increaseValue(): this {
    if ($this->stackable) {
      if ($this->value is null) {
        $this->value = 1;
      } else {
        $this->value++;
      }
    }

    return $this;
  }

  /**
   * Retrieve whether the `Flag` is stackable or not.
   */
  public function isStackable(): bool {
    return $this->stackable;
  }

  /**
   * Set an alias for the `Flag`. If the 'name' given at construction is a short
   * name and the alias set is long, the 'alias' given here will serve as the
   * 'name' and the original name will be set to the 'alias'.
   */
  <<__Override>>
  public function setAlias(string $alias): this {
    parent::setAlias($alias);

    if (Str\length($this->getName()) > 1) {
      $this->negativeAlias = 'no-'.$this->getName();
    }

    return $this;
  }

  /**
   * Set whether the `Flag` is stackable or not.
   */
  public function setStackable(bool $stackable): this {
    $this->stackable = $stackable;

    return $this;
  }
}
