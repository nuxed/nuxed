/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Console\Input;

use namespace HH\Lib\{C, Regex, Str, Vec};

/**
 * The `Lexer` handles all parsing and pairing of the provided input.
 */
final class Lexer
  implements Iterator<shape(
    'raw' => string,
    'value' => string,
  )> {
  /**
   * Data structure of all items that have yet to be retrieved.
   */
  public vec<string> $items;

  /**
   * The current position in the `items` of the lexer.
   */
  protected int $position = 0;

  /**
   * The current length of available values remaining in the lexer.
   */
  protected int $length = 0;

  /**
   * The current value the lexer is pointing to.
   */
  protected shape(
    'raw' => string,
    'value' => string,
  ) $current;

  /**
   * Whether the lexer is on its first item or not.
   */
  protected bool $first = true;

  /**
   * Construct a new `InputLexer` given the provided structure of inputs.
   *
   * @param Container<string> $items  The items to traverse through
   */
  public function __construct(Container<string> $items) {
    $this->items = vec<string>($items);
    $this->length = C\count($items);
    $this->current = shape(
      'value' => '',
      'raw' => '',
    );
  }

  /**
   * Retrieve the current item the lexer is pointing to.
   */
  public function current(): shape(
    'raw' => string,
    'value' => string,
  ) {
    return $this->current;
  }

  /**
   * Return whether the lexer has reached the end of its parsable items or not.
   */
  public function end(): bool {
    return ($this->position + 1) === $this->length;
  }

  /**
   * If the current item is a string of short input values or the string contains
   * a value a flag is representing, separate them and add them to the available
   * items to parse.
   */
  private function explode(): void {
    if (
      !static::isShort($this->current['raw']) ||
      Str\length($this->current['value']) <= 1
    ) {
      return;
    }

    $exploded = Str\chunk($this->current['value']);

    $this->current = shape(
      'value' => C\lastx<string>($exploded),
      'raw' => '-'.$this->current['value'],
    );

    foreach (Vec\take<string>($exploded, C\count($exploded) - 1) as $piece) {
      $this->unshift('-'.$piece);
    }
  }

  /**
   * Return whether the given value is representing notation for an argument.
   */
  <<__Memoize>>
  public static function isAnnotated(string $value): bool {
    return static::isLong($value) || static::isShort($value);
  }

  /**
   * Determine if the given value is representing a long argument (i.e., --foo).
   */
  <<__Memoize>>
  public static function isLong(string $value): bool {
    return Str\starts_with($value, '--');
  }

  /**
   * Determine if the given value is representing a short argument (i.e., -f).
   */
  <<__Memoize>>
  public static function isShort(string $value): bool {
    return !static::isLong($value) && Str\starts_with($value, '-');
  }

  /**
   * Retrieve the current position of the lexer.
   */
  public function key(): int {
    return $this->position;
  }

  /**
   * Progress the lexer to its next item (if available).
   */
  public function next(): void {
    if ($this->valid()) {
      $this->shift();
    }
  }

  /**
   * Peek ahead to the next available item without progressing the lexer.
   */
  public function peek(): ?shape(
    'raw' => string,
    'value' => string,
  ) {
    if (C\count($this->items) > 0) {
      return $this->processInput($this->items[0]);
    }

    return null;
  }

  /**
   * Create and return RawInput given a raw string value.
   */
  <<__Memoize>>
  public function processInput(string $input): shape(
    'raw' => string,
    'value' => string,
  ) {
    $raw = $input;
    $value = $input;

    if (static::isLong($input)) {
      $value = Str\slice($input, 2);
    } else if (static::isShort($input)) {
      $value = Str\slice($input, 1);
    }

    return shape(
      'raw' => $raw,
      'value' => $value,
    );
  }

  /**
   * {@inheritdoc}
   */
  public function rewind(): void {
    $this->shift();
    if ($this->first) {
      $this->position = 0;
      $this->first = false;
    }
  }

  /**
   * Progress the lexer to its next available item. If the item contains a value
   * an argument is representing, separate them and add the value back to the
   * available items to parse.
   */
  public function shift(): void {
    $key = C\first<string>($this->items);
    $this->items = Vec\drop<string>($this->items, 1);

    $matches = vec[];
    if ($key is nonnull && Regex\matches($key, re"#\A([^\s'\"=]+)=(.+?)$#")) {
      $matches = Regex\first_match($key, re"#\A([^\s'\"=]+)=(.+?)$#")
        as nonnull;
      $key = $matches[1];
      $this->items = Vec\concat<string>(vec[$matches[2]], $this->items);
    } else {
      $this->position++;
    }

    if ($key is null) {
      return;
    }

    $this->current = $this->processInput($key);

    $this->explode();
  }

  /**
   * Add an item back to the items that have yet to be parsed.
   */
  public function unshift(string $item): void {
    $this->items = Vec\concat<string>(vec[$item], $this->items);
    $this->length++;
  }

  /**
   * Return whether or not the lexer has any more items to parse.
   */
  public function valid(): bool {
    return ($this->position < $this->length);
  }
}
