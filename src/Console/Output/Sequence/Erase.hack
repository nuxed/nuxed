/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Console\Output\Sequence;

/**
 * @see http://ascii-table.com/ansi-escape-sequences.php
 */
enum Erase: string as string {
  DISPLAY = "\033[2J";
  LINE = "\033[K";
}
