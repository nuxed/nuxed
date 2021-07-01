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
 * Fetches a variable from the environment.
 */
function get(string $name, ?string $default = null): ?string {
  $value = \getenv(_Private\Parser::parseName($name));
  if ($value is bool) {
    return $default;
  }

  return _Private\Parser::parseValue($value);
}
