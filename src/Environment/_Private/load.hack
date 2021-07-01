/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Environment\_Private;

use namespace HH\Lib\{File, IO, Str};
use namespace Nuxed\Environment;

/**
 * Load a .env file into the current environment.
 */
async function load(string $file, bool $override = false): Awaitable<void> {
  $file = File\open_read_only($file);
  $reader = new IO\BufferedReader($file);

  $lastOperation = async {
  };
  foreach ($reader->linesIterator() await as $line) {
    $lastOperation = async {
      await $lastOperation;

      $trimmed = Str\trim($line);
      // ignore comments and empty lines
      if (Str\starts_with($trimmed, '#') || Str\is_empty($trimmed)) {
        return;
      }

      list($name, $value) = Environment\parse($line);
      if ($value is nonnull) {
        $override
          ? Environment\put($name, $value)
          : Environment\add($name, $value);
      }
    };
  }

  await $lastOperation;
  $file->close();
}
