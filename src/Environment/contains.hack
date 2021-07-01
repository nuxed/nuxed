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
 * Determine if a variable exists in the environment.
 */
function contains(string $name): bool {
  return get($name, null) is nonnull;
}
