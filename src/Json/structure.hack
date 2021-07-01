/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Json;

use namespace Facebook\TypeAssert;

/**
 * Decode a json encoded string and match the provided type structure.
 */
function structure<T>(string $json, TypeStructure<T> $structure): T {
  try {
    return TypeAssert\matches_type_structure($structure, decode($json));
  } catch (TypeAssert\IncorrectTypeException $e) {
    throw new Exception\JsonDecodeException(
      $e->getMessage(),
      $e->getCode(),
      $e,
    );
  }
}
