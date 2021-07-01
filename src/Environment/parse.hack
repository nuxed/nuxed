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
 * Parse the given environment variable entry into a name and value.
 */
function parse(string $entry): (string, ?string) {
  return _Private\Parser::parse($entry);
}
