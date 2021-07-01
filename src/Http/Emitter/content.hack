/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http\Emitter;

use namespace HH\Lib\IO;

/**
 * Emit the response content back to the client.
 */
async function content(
  IO\SeekableReadHandle $source,
  ?IO\WriteHandle $target = null,
  int $maxBufferLength = 8192,
): Awaitable<bool> {
  $target ??= IO\request_output();
  return await _Private\copy($source, $target, $maxBufferLength);
}
