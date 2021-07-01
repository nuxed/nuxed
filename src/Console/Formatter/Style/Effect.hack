/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Console\Formatter\Style;

enum Effect: string as string {
  BOLD = '1';
  UNDERLINE = '4';
  BLINK = '5';
  REVERSE = '7';
  CONCEAL = '8';
}
