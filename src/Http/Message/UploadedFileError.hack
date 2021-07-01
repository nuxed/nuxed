/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Message;

enum UploadedFileError: int as int {
  NONE = 0;
  EXCEEDS_MAX_SIZE = 1;
  EXCEEDS_MAX_FORM_SIZE = 2;
  INCOMPLETE = 3;
  NO_FILE = 4;
  TEMPORARY_DIRECTORY_NOT_SPECIFIED = 5;
  TEMPORARY_DIRECTORY_NOT_WRITABLE = 6;
  CANCELED_BY_EXTENSION = 7;
}
