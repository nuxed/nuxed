/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Emitter\_Private;

use namespace HH\Lib\IO;
use namespace Nuxed\Http\Message;

async function stream(
  Message\IResponse $response,
  IO\WriteHandle $target,
  int $maxBufferLength,
): Awaitable<bool> {
  $header = $response->getHeaderLine('Content-Range');
  $source = $response->getBody();

  $range = range($header);
  if ($range is null || $range['unit'] !== 'bytes') {
    return false;
  }

  $remaining = $range['last'] - $range['first'] + 1;
  $source->seek($range['first']);
  $remaining = await copy_range($source, $target, $maxBufferLength, $remaining);
  if ($remaining > 0) {
    $contents = await $source->readAllAsync($remaining);
    if ('' !== $contents) {
      await $target->writeAllAsync($contents);
    }
  }

  return true;
}
