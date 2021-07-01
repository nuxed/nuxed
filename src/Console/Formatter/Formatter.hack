/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Console\Formatter;

use namespace HH\Lib\{C, PseudoRandom, Regex, Str, Vec};
use namespace Nuxed\Console;

class Formatter extends AbstractFormatter implements IWrappableFormatter {
  const KeyedContainer<string, this::Style> DefaultStyles = dict[
    'comment' => shape(
      'foreground' => Style\ForegroundColor::YELLOW,
    ),
    'success' => shape(
      'foreground' => Style\ForegroundColor::GREEN,
    ),
    'warning' => shape(
      'foreground' => Style\ForegroundColor::YELLOW,
      'background' => Style\BackgroundColor::BLACK,
    ),
    'info' => shape(
      'foreground' => Style\ForegroundColor::BLUE,
    ),
    'question' => shape(
      'foreground' => Style\ForegroundColor::CYAN,
      'background' => Style\BackgroundColor::BLACK,
    ),
    'error' => shape(
      'foreground' => Style\ForegroundColor::WHITE,
      'background' => Style\BackgroundColor::RED,
    ),
  ];

  protected Style\StyleStack $styleStack;

  public function __construct(
    KeyedContainer<string, Style\IStyle> $styles = dict[],
  ) {
    parent::__construct($styles);

    $this->styleStack = new Style\StyleStack();
  }

  /**
   * {@inheritdoc}
   */
  <<__Override>>
  public function format(string $message, int $width = 0): string {
    $offset = 0;
    $output = '';
    $currentLineLength = 0;
    $matches = vec[];
    \preg_match_all_with_matches(
      '#<(([a-z][^<>]*+) | /([a-z][^<>]*+)?)>#ix',
      $message,
      inout $matches,
      \PREG_OFFSET_CAPTURE,
    );

    foreach ($matches[0] as $i => $match) {
      $pos = (int)$match[1];
      $text = $match[0];
      if (0 !== $pos && '\\' === $message[$pos - 1]) {
        continue;
      }

      // add the text up to the next tag
      $output .= $this->applyCurrentStyle(
        Str\slice($message, $offset, $pos - $offset),
        $output,
        $width,
        inout $currentLineLength,
      );
      $offset = $pos + Str\length($text);
      // opening tag?
      $open = '/' !== $text[1];
      if ($open) {
        $tag = $matches[1][$i][0];
      } else {
        $tag = $matches[3][$i][0] ?? '';

      }
      if (!$open && !$tag) {
        // </>
        $this->styleStack->pop();
      } else {
        $style = $this->createStyleFromString($tag);
        if ($style is null) {
          $output .= $this->applyCurrentStyle(
            $text,
            $output,
            $width,
            inout $currentLineLength,
          );
        } else if ($open) {
          $this->styleStack->push($style);
        } else {
          $this->styleStack->pop($style);
        }
      }
    }

    $output .= $this->applyCurrentStyle(
      Str\slice($message, $offset),
      $output,
      $width,
      inout $currentLineLength,
    );

    if (Str\contains($output, "\0")) {
      $output = Str\replace($output, "\0", '\\');
    }

    return Str\replace($output, '\\<', '<');
  }

  /**
   * Tries to create new style instance from string.
   */
  private function createStyleFromString(string $string): ?Style\IStyle {
    if (C\contains_key<string, string, Style\IStyle>($this->styles, $string)) {
      return $this->styles[$string];
    }

    $attributes = Str\replace($string, ';', ' ')
      |> Str\trim($$)
      |> Str\split($$, ' ');

    if (C\is_empty<string>($attributes)) {
      return null;
    }

    $style = new Style\Style();
    $valid = false;
    $backgrounds = dict<string, Style\BackgroundColor>(
      Style\BackgroundColor::getValues(),
    );
    $foregrounds = dict<string, Style\ForegroundColor>(
      Style\ForegroundColor::getValues(),
    );
    $effects = dict<string, Style\Effect>(Style\Effect::getValues());

    foreach ($attributes as $attribute) {
      if (
        Str\starts_with($attribute, 'bg=') ||
        Str\starts_with($attribute, 'background=')
      ) {
        $background = Str\split($attribute, '=', 2)
          |> C\lastx<string>($$)
          |> Str\replace_every($$, dict['"' => '', '\'' => ''])
          |> Str\uppercase($$);

        if ('' === $background) {
          continue;
        }

        if ('RANDOM' === $background) {
          $possible = Vec\keys($backgrounds);
          $element = PseudoRandom\int(0, C\count($possible) - 1);
          $background = $possible[$element];
        } else if (
          !C\contains_key<string, string, Style\BackgroundColor>(
            $backgrounds,
            $background,
          )
        ) {
          throw new Console\Exception\InvalidCharacterSequenceException(
            Str\format('Background "%s" does not exists.', $background),
          );
        }

        $valid = true;
        $style->setBackground($backgrounds[$background]);
        continue;
      }

      if (
        Str\starts_with($attribute, 'fg=') ||
        Str\starts_with($attribute, 'foreground=')
      ) {
        $foreground = Str\split($attribute, '=', 2)
          |> C\lastx($$)
          |> Str\replace_every($$, dict['"' => '', '\'' => ''])
          |> Str\uppercase($$);

        if ('' === $foreground) {
          continue;
        }

        if ('RANDOM' === $foreground) {
          $possible = Vec\keys($foregrounds);
          $element = PseudoRandom\int(0, C\count($possible) - 1);
          $foreground = $possible[$element];

        } else if (
          !C\contains_key<string, string, Style\ForegroundColor>(
            $foregrounds,
            $foreground,
          )
        ) {
          throw new Console\Exception\InvalidCharacterSequenceException(
            Str\format('Foreground "%s" does not exists.', $foreground),
          );
        }

        $valid = true;
        $style->setForeground($foregrounds[$foreground]);
        continue;
      }

      $effect = Str\uppercase($attribute);
      if (!C\contains_key($effects, $effect)) {
        continue;
      }

      $valid = true;
      $style->setEffect($effects[$effect]);
    }

    return $valid ? $style : null;
  }

  /**
   * Applies current style from stack to text, if must be applied.
   */
  private function applyCurrentStyle(
    string $text,
    string $current,
    int $width,
    inout int $currentLineLength,
  ): string {
    if ('' === $text) {
      return '';
    }

    if (0 === $width) {
      return Console\Terminal::isDecorated()
        ? $this->styleStack->getCurrent()->apply($text)
        : $text;
    }

    if (0 === $currentLineLength && '' !== $current) {
      $text = Str\trim_left($text);
    }

    if ($currentLineLength > 0) {
      $i = $width - $currentLineLength;
      $prefix = Str\slice($text, 0, $i)."\n";
      $text = Str\slice($text, $i);
    } else {
      $prefix = '';
    }

    $matches = Regex\first_match($text, re"~(\\n)$~");
    /* HH_IGNORE_ERROR[4110] ~ regex ~ */
    $text = $prefix.Regex\replace($text, '~([^\\n]{'.$width.'})\\ *~', "\$1\n");
    $text = Str\trim_right($text, "\n").($matches[1] ?? '');
    if (
      !$currentLineLength && '' !== $current && "\n" !== Str\slice($current, -1)
    ) {
      $text = "\n".$text;
    }

    $lines = Str\split($text, "\n");
    foreach ($lines as $line) {
      $currentLineLength += Str\length($line);
      if ($width <= $currentLineLength) {
        $currentLineLength = 0;
      }
    }

    if (Console\Terminal::isDecorated()) {
      foreach ($lines as $i => $line) {
        $lines[$i] = $this->styleStack->getCurrent()->apply($line);
      }
    }

    return Str\join($lines, "\n");
  }
}
