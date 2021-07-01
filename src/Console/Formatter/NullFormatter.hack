/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Console\Formatter;

final class NullFormatter
  extends AbstractFormatter
  implements IWrappableFormatter {

  /**
   * {@inheritdoc}
   */
  <<__Override>>
  public function format(string $message, int $_width = 0): string {
    return $message;
  }
}
