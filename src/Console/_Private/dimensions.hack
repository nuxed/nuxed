/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Console\_Private;

use namespace HH\Lib\{Regex, Str};

/**
 * Initializes dimensions using the output of an stty columns line.
 */
<<__Memoize>>
async function dimensions(
): Awaitable<shape('width' => ?int, 'height' => ?int)> {
  $sttyString = await get_stty_columns();
  if ($sttyString is nonnull) {
    if (Regex\matches($sttyString, re"/rows.(\d+);.columns.(\d+);/i")) {
      $matches = Regex\first_match(
        $sttyString,
        re"/rows.(\d+);.columns.(\d+);/i",
      ) as nonnull;

      // extract [w, h] from "rows h; columns w;"
      return shape(
        'width' => Str\to_int($matches[2]) as int,
        'height' => Str\to_int($matches[1]) as int,
      );
    } else if (Regex\matches($sttyString, re"/;.(\d+).rows;.(\d+).columns/i")) {
      $matches = Regex\first_match(
        $sttyString,
        re"/;.(\d+).rows;.(\d+).columns/i",
      ) as nonnull;

      // extract [w, h] from "; h rows; w columns"
      return shape(
        'width' => Str\to_int($matches[2]) as int,
        'height' => Str\to_int($matches[1]) as int,
      );
    }
  }

  // default
  return shape(
    'width' => null,
    'height' => null,
  );
}
