/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Console\Formatter\Style;

use namespace HH\Lib\{C, Str};
use namespace Nuxed\Environment;

final class Style implements IStyle {
  private ?(ForegroundColor, string) $foreground = null;
  private ?(BackgroundColor, string) $background = null;
  private vec<(Effect, string)> $effects = vec[];
  private ?string $href = null;
  private ?bool $handlesHrefGracefully = null;

  public function __construct(
    ?BackgroundColor $background = null,
    ?ForegroundColor $foreground = null,
    Container<Effect> $effects = vec[],
  ) {
    $this->setForeground($foreground);
    $this->setBackground($background);
    $this->setEffects($effects);
  }

  /**
   * {@inheritdoc}
   */
  public function setForeground(?ForegroundColor $color = null): this {
    if ($color is null) {
      $this->foreground = null;
      return $this;
    }

    $this->foreground = tuple($color, '39');

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  public function setBackground(?BackgroundColor $color = null): this {
    if ($color is null) {
      $this->background = null;
      return $this;
    }

    $this->background = tuple($color, '49');

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  public function setEffect(Effect $effect): this {
    switch ($effect) {
      case Effect::BOLD:
        $closing = '22';
        break;
      case Effect::UNDERLINE:
        $closing = '24';
        break;
      case Effect::BLINK:
        $closing = '25';
        break;
      case Effect::REVERSE:
        $closing = '27';
        break;
      case Effect::CONCEAL:
        $closing = '28';
        break;
    }

    $this->effects[] = tuple($effect as string, $closing);

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  public function setEffects(Container<Effect> $effects): this {
    foreach ($effects as $effect) {
      $this->setEffect($effect);
    }

    return $this;
  }

  /**
   * @ignore
   */
  public function setHref(string $url): this {
    $this->href = $url;

    return $this;
  }

  /**
   * {@inheritdoc}
   */
  <<__Memoize>>
  public function apply(string $text): string {
    $setCodes = vec[];
    $unsetCodes = vec[];
    if ($this->handlesHrefGracefully is null) {
      $this->handlesHrefGracefully = 'JetBrains-JediTerm' !==
        Environment\get('TERMINAL_EMULATOR') &&
        !Environment\contains('KONSOLE_VERSION');
    }

    if ($this->foreground is nonnull) {
      list($set, $unset) = $this->foreground;
      $setCodes[] = $set;
      $unsetCodes[] = $unset;
    }

    if ($this->background is nonnull) {
      list($set, $unset) = $this->background;
      $setCodes[] = $set;
      $unsetCodes[] = $unset;
    }

    foreach ($this->effects as list($set, $unset)) {
      $setCodes[] = $set;
      $unsetCodes[] = $unset;
    }

    if ($this->href is nonnull && $this->handlesHrefGracefully) {
      $text = Str\format(
        "\033]8;;%s\033\\%s\033]8;;\033\\",
        $this->href,
        $text,
      );
    }

    if (C\is_empty<string>($setCodes)) {
      return $text;
    }

    return Str\format(
      "\033[%sm%s\033[%sm",
      Str\join($setCodes, ';'),
      $text,
      Str\join($unsetCodes, ';'),
    );
  }
}
