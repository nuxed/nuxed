/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Console\Formatter;

use namespace HH\Lib\{C, Str};

abstract class AbstractFormatter implements IWrappableFormatter {
  const type Style = shape(
    ?'foreground' => Style\ForegroundColor,
    ?'background' => Style\BackgroundColor,
    ?'effects' => Container<Style\Effect>,
  );

  const KeyedContainer<string, this::Style> DefaultStyles = dict[];

  protected dict<string, Style\IStyle> $styles = dict[];

  public function __construct(
    KeyedContainer<string, Style\IStyle> $styles = dict[],
  ) {
    foreach (static::DefaultStyles as $name => $style) {
      $style = new Style\Style(
        $style['background'] ?? null,
        $style['foreground'] ?? null,
        $style['effects'] ?? vec[],
      );

      $this->styles[$name] = $style;
    }

    foreach ($styles as $name => $style) {
      $this->addStyle($name, $style);
    }
  }

  /**
   * {@inheritdoc}
   */
  public function addStyle(string $name, Style\IStyle $style): this {
    $this->styles[Str\lowercase($name)] = $style;

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  public function hasStyle(string $name): bool {
    return C\contains_key<string, string, Style\IStyle>(
      $this->styles,
      Str\lowercase($name),
    );
  }

  /**
   * {@inheritdoc}
   */
  public function getStyle(string $name): Style\IStyle {
    return $this->styles[Str\lowercase($name)];
  }
}
