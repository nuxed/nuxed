/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Environment\_Private;

enum State: int {
  INITIAL = 0;
  UNQUOTED = 1;
  QUOTED = 2;
  ESCAPE = 3;
  WHITESPACE = 4;
  COMMENT = 5;
}
