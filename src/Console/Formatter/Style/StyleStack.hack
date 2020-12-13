namespace Nuxed\Console\Formatter\Style;

use namespace HH\Lib\{C, Vec};
use namespace Nuxed\Console\Exception;

final class StyleStack {
  private vec<IStyle> $styles = vec[];
  private IStyle $emptyStyle;

  public function __construct(?IStyle $emptyStyle = null) {
    $this->emptyStyle = $emptyStyle ?? new Style();
  }

  public function reset(): void {
    $this->styles = vec[];
  }

  /**
   * Pushes a style in the stack.
   */
  public function push(IStyle $style): this {
    $this->styles[] = $style;

    return $this;
  }

  /**
   * Pops a style from the stack.
   */
  public function pop(?IStyle $style = null): IStyle {
    if (C\is_empty<IStyle>($this->styles)) {
      return $this->emptyStyle;
    }

    if ($style is null) {
      $lastStyle = C\lastx<IStyle>($this->styles);
      $this->styles = Vec\take<IStyle>(
        $this->styles,
        C\count($this->styles) - 1,
      );
      return $lastStyle;
    }

    // we need to preserve the index order when reversing the stack
    $styles = vec[];
    foreach ($this->styles as $index => $stackedStyle) {
      $styles[] = tuple($index, $stackedStyle);
    }

    $styles = Vec\reverse<(int, IStyle)>($styles);
    foreach ($styles as list($index, $stackedStyle)) {
      if ($style->apply('') === $stackedStyle->apply('')) {
        $this->styles = Vec\slice<IStyle>($this->styles, 0, $index);

        return $stackedStyle;
      }
    }

    throw new Exception\InvalidArgumentException(
      'Incorrectly nested style tag found.',
    );
  }

  public function getCurrent(): IStyle {
    return C\last<IStyle>($this->styles) ?? $this->emptyStyle;
  }

  public function setEmptyStyle(IStyle $style): this {
    $this->emptyStyle = $style;

    return $this;
  }

  public function getEmptyStyle(): IStyle {
    return $this->emptyStyle;
  }
}
