namespace Nuxed\Console;

use namespace HH;
use namespace HH\Lib\{IO, Str};
use namespace Nuxed\Environment;

final abstract class Terminal {
  const int DefaultHeight = 60;
  const int DefaultWidth = 120;

  private static ?int $height = null;
  private static ?int $width = null;
  private static ?bool $decorated = null;
  private static ?bool $interactive = null;

  /**
   * Set the terminal height.
   */
  public static function setHeight(?int $height): void {
    static::$height = $height;
  }

  /**
   * Set the terminal width.
   */
  public static function setWidth(?int $width): void {
    static::$width = $width;
  }

  /**
   * Set to `true` to mark this terminal as decorated.
   */
  public static function setDecorated(?bool $decorated): void {
    static::$decorated = $decorated;
  }

  /**
   * Set to `true` to mark this terminal as interactive.
   */
  public static function setInteractive(?bool $interactive): void {
    static::$interactive = $interactive;
  }

  public static function getInputHandle(): IO\ReadHandle {
    return IO\request_input();
  }

  public static function getOutputHandle(): IO\WriteHandle {
    return IO\request_output();
  }

  public static function getErrorHandle(): ?IO\WriteHandle {
    return IO\request_error();
  }

  /**
   * Retrieve the height of the current terminal window.
   */
  public static async function getHeight(): Awaitable<int> {
    $lines = Environment\get('LINES');
    if ($lines is nonnull) {
      $lines = Str\to_int($lines);
      if ($lines is nonnull) {
        return $lines;
      }
    }

    if (static::$height is nonnull) {
      return static::$height;
    }

    $dimensions = await _Private\dimensions();

    static::$height = $dimensions['height'] ?? self::DefaultHeight;
    return static::$height;
  }

  /**
   * Retrieve the width of the current terminal window.
   */
  public static async function getWidth(): Awaitable<int> {
    $cols = Environment\get('COLUMNS');
    if ($cols is nonnull) {
      $cols = Str\to_int($cols);
      if ($cols is nonnull) {
        return $cols;
      }
    }

    if (static::$width is nonnull) {
      return static::$width;
    }

    $dimensions = await _Private\dimensions();
    static::$width = $dimensions['width'] ?? self::DefaultWidth;

    return static::$width;
  }

  /**
   * Gets the decorated flag.
   *
   * @return bool true if the output will decorate messages, false otherwise
   */
  public static function isDecorated(): bool {
    if (static::$decorated is nonnull) {
      return static::$decorated;
    }

    // follow https://no-color.org
    if (Environment\contains('NO_COLOR')) {
      static::$decorated = false;
      return static::$decorated;
    }

    $colors = Environment\get('CLICOLORS');
    if ($colors is nonnull) {
      if (
        $colors === '1' ||
        $colors === 'yes' ||
        $colors === 'true' ||
        $colors === 'on'
      ) {
        return true;
      }

      if (
        $colors === '0' ||
        $colors === 'no' ||
        $colors === 'false' ||
        $colors === 'off'
      ) {
        return false;
      }
    }

    if (Environment\get('TRAVIS') is nonnull) {
      return true;
    }

    if (Environment\get('CIRCLECI') is nonnull) {
      return true;
    }

    if (Environment\get('TERM') === 'xterm') {
      return true;
    }

    if (Environment\get('TERM_PROGRAM') === 'Hyper') {
      return true;
    }

    if (static::isInteractive()) {
      return Str\contains_ci(Environment\get('TERM', '') as string, 'color');
    }

    return false;
  }

  /**
   * Determines whether the current terminal is in interactive mode.
   *
   * In general, this is `true` if the user is directly typing into stdin.
   */
  public static function isInteractive(): bool {
    if (static::$interactive is nonnull) {
      return static::$interactive;
    }

    $noninteractive = Environment\get('NONINTERACTIVE');
    if ($noninteractive is nonnull) {
      if (
        $noninteractive === '1' ||
        $noninteractive === 'true' ||
        $noninteractive === 'yes'
      ) {
        static::$interactive = false;

        return static::$interactive;
      }

      if (
        $noninteractive === '0' ||
        $noninteractive === 'false' ||
        $noninteractive === 'no'
      ) {
        static::$interactive = true;

        return static::$interactive;
      }
    }

    // Detects TravisCI and CircleCI; Travis gives you a TTY for STDIN
    $ci = Environment\get('CI');
    if ($ci === '1' || $ci === 'true') {
      static::$interactive = false;

      return static::$interactive;
    }

    // Generic
    if (\posix_isatty(\STDIN) && \posix_isatty(\STDOUT)) {
      static::$interactive = true;

      return static::$interactive;
    }

    // Fail-safe
    return false;
  }
}
