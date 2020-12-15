namespace Nuxed\Log\Formatter;

use namespace HH\Lib\{C, Dict, Str};
use namespace Nuxed\Log;

final class LineFormatter implements IFormatter {
  const string SIMPLE_DATE = 'Y-m-d\TH:i:s.uP';
  const string SIMPLE_FORMAT = "[%time%][%level%]: %message% %context%\n";

  private string $format;
  private string $dateFormat;
  private bool $allowInlineLineBreaks;
  private bool $ignoreEmptyContext;

  /**
   * @param string|null $format                     The format of the message
   * @param string|null $dateFormat                 The format of the timestamp: one supported by DateTime::format
   * @param bool        $allowInlineLineBreaks      Whether to allow inline line breaks in log entries
   * @param bool        $ignoreEmptyContext
   */
  <<__Override>>
  public function __construct(
    ?string $format = null,
    ?string $dateFormat = null,
    bool $allowInlineLineBreaks = false,
    bool $ignoreEmptyContext = true,
  ) {
    $this->dateFormat = $dateFormat ?? static::SIMPLE_DATE;
    $this->format = $format is null ? static::SIMPLE_FORMAT : $format;
    $this->ignoreEmptyContext = $ignoreEmptyContext;
    $this->allowInlineLineBreaks = $allowInlineLineBreaks;
  }

  public async function format<<<__Enforceable>> reify T>(
    Log\LogLevel $level,
    string $message,
    KeyedContainer<string, T> $context,
  ): Awaitable<string> {
    $context = dict<string, T>($context);
    $output = $this->format;

    foreach ($context as $var => $val) {
      if (Str\search($output, '%context.'.$var.'%') is nonnull) {
        $output = \strtr(
          $output,
          '%context.'.$var.'%',
          $this->stringify<T>($val),
        );
        unset($context[$var]);
      }
    }

    if ($this->ignoreEmptyContext) {
      if (0 === C\count($context)) {
        $output = Str\replace($output, '%context%', '');
      }
    }

    $replaces = dict[
      '%message%' => $message,
      '%time%' => (new \DateTime())->format($this->dateFormat),
      '%level%' => Str\uppercase((string)$level),
      '%context%' => $this->stringify<dict<string, T>>($context),
    ];

    return \strtr($output, $replaces);
  }

  public function stringify<reify T>(T $value): string {
    return $this->replaceNewlines(Log\_Private\stringify($value));
  }

  protected function replaceNewlines(string $str): string {
    if ($this->allowInlineLineBreaks) {
      if (0 === Str\search($str, '{')) {
        return \strtr($str, Dict\associate(vec['\r', '\n'], vec["\r", "\n"]));
      }

      return $str;
    }

    return \strtr(
      $str,
      Dict\associate(vec["\r\n", "\r", "\n"], vec[' ', ' ', ' ']),
    );
  }

}
