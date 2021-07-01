/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Console\Command\Loader;

use namespace Nuxed\Console\Command;

interface ILoader {
  /**
   * Loads a command.
   */
  public function get(string $name): Command\Command;

  /**
   * Checks if a command exists.
   */
  public function has(string $name): bool;

  /**
   * @return string[] All registered command names
   */
  public function getNames(): Container<string>;
}
