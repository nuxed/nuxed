/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Message\Body;

use namespace HH\Lib\{File, IO};

function memory(string $content = ''): IO\SeekableReadWriteHandle {
  return new IO\MemoryHandle($content);
}

function file(
  string $path,
  File\WriteMode $mode = File\WriteMode::OPEN_OR_CREATE,
): IO\SeekableReadWriteHandle {
  return File\open_read_write($path, $mode);
}
