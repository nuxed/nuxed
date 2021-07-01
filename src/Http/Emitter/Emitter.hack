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

final class Emitter implements IEmitter {
  private ?IO\WriteHandle $output;

  /**
   * @param int $maxBufferLength Maximum output buffering size for each iteration
   */
  public function __construct(
    private int $maxBufferLength = 8192,
    ?IO\WriteHandle $output = null,
  ) {
    $this->output = $output;
  }

  /**
   * Emit a response.
   *
   * Emits a response, including status line, headers, and the message body,
   * according to the environment.
   *
   * @return a boolean. A boolean `true` indicates that the emitter was able
   * to emit the response, while `false` indicates it was not.
   */
  public function emit(Message\IResponse $response): Awaitable<bool> {
    return emit($response, $this->output, $this->maxBufferLength);
  }
}
