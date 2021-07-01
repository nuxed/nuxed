/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Console\Style;

use namespace Nuxed\Console\Output;

interface IOutputStyle extends IStyle, Output\IOutput {
  /**
   * Return the underlying output object.
   */
  public function getOutput(): Output\IOutput;
}
