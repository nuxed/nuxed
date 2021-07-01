/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Environment;

/**
 * Loads one or several .env files into the current environment.
 */
async function load(string ...$files): Awaitable<void> {
  $lastOperation = async {
  };
  foreach ($files as $file) {
    $lastOperation = async {
      await $lastOperation;
      await _Private\load($file, false);
    };
  }

  await $lastOperation;
}
