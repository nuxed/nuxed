/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Console\Formatter\Style;

/**
 * Formatter style interface for defining styles.
 */
interface IStyle {
  /**
   * Sets style foreground color.
   */
  public function setForeground(?ForegroundColor $color = null): this;

  /**
   * Sets style background color.
   */
  public function setBackground(?BackgroundColor $color = null): this;

  /**
   * Sets some specific style effect.
   */
  public function setEffect(Effect $effect): this;

  /**
   * Sets multiple style effects at once.
   */
  public function setEffects(Container<Effect> $effects): this;

  /**
   * Applies the style to a given text.
   */
  public function apply(string $text): string;
}
