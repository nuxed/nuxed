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
 * Loads one or several .env files into the current environment
 * and enables override existing variables.
 */
async function overload(string ...$files): Awaitable<void> {
  $lastOperation = async {
  };
  foreach ($files as $file) {
    $lastOperation = async {
      await $lastOperation;
      await _Private\load($file, true);
    };
  }

  await $lastOperation;
}
