/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Json;

use namespace Facebook\TypeSpec;

/**
 * Decoded a json encoded string, and assert, or coerce the type to the provided reified type.
 */
function typed<reify T>(string $json): T {
  return spec($json, TypeSpec\of<T>());
}
