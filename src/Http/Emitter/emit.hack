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

/**
 * Emits a response, including status line, headers, and the message body,
 * according to the environment.
 *
 * @return bool - A boolean `true` indicates that
 *                the emitter was able to emit the response, while `false` indicates
 *                it was not.
 */
async function emit(
  Message\IResponse $response,
  ?IO\WriteHandle $target = null,
  int $maxBufferLength = 8192,
): Awaitable<bool> {
  // Emit status line.
  status(
    $response->getProtocolVersion(),
    $response->getStatusCode(),
    $response->getReasonPhrase(),
  );
  // emit cookies.
  cookies($response->getCookies());
  // emit headers.
  headers($response->getHeaders());
  // attempt to stream the response.
  $result = await stream($response, $target, $maxBufferLength);

  if (!$result) {
    $source = $response->getBody();
    // send the response content as is to the client if the stream
    // failed.
    $result = await content($source, $target, $maxBufferLength);
  }

  return $result;
}
