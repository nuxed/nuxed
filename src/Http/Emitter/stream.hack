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
use namespace Nuxed\Http\Message;

async function stream(
  Message\IResponse $response,
  ?IO\WriteHandle $target = null,
  int $maxBufferLength = 8192,
): Awaitable<bool> {
  $target ??= IO\request_output();
  $result = false;
  if ($response->hasHeader('Content-Range')) {
    $result = await _Private\stream($response, $target, $maxBufferLength);
  }

  return $result;
}
