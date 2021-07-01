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
 * Remove a variable from the environment.
 */
function forget(string $name): void {
  \putenv(_Private\Parser::parseName($name));
}
