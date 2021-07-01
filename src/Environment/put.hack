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
 * Store a variable in the environment.
 */
function put(string $name, string $value): void {
  list($name, $value) = parse($name.'='.$value);
  \putenv($name.'='.$value);
}
