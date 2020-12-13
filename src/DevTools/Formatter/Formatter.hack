namespace Nuxed\DevTools\Formatter;

use namespace HH\Lib\Str;
use namespace Nuxed\{Filesystem, Process};

final class Formatter implements IFormatter {
  /**
   * Format the given code.
   */
  public async function format(
    string $code,
    int $width = 80,
    int $indent = 2,
    bool $tabs = false,
  ): Awaitable<Result> {
    $args = vec[
      '--indent-width',
      (string)$indent,
      '--line-width',
      (string)$width,
    ];

    if ($tabs) {
      $args[] = '--tabs';
    }

    $file = await Filesystem\File::temporary('nuxed_formatter');
    await $file->write($code);

    $result = await Process\execute(
      'hackfmt',
      $file->path()->toString(),
      ...$args
    );

    try {
      $status = Status::NO_CHANGES;
      $new_code = $result->getOutput(true);
      if (Str\starts_with($new_code, "\n")) {
        $new_code = Str\slice($new_code, 1);
      }

      if ($new_code !== $code) {
        $status = Status::FORMATTED;
      }
    } catch (Process\Exception\SubprocessException $e) {
      $status = Status::INVALID;
      $new_code = '';
    }


    return new Result($new_code, $status);
  }
}
