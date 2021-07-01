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
 * add a variable to the environment if it doesn't exist.
 */
function add(string $name, string $value): void {
  if (!contains($name)) {
    put($name, $value);
  }
}
