/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http\Emitter;

use namespace HH\Lib\Str;
use namespace Nuxed\Http\Exception;

/**
 * Emit the status line.
 *
 * Emits the status line using the given protocol version and status code;
 * if a reason phrase is given, it, too, is emitted.
 */
function status(string $protocol, int $status, ?string $reason = null): void {
  _Private\assert_not_sent();
  if (
    !Str\contains($protocol, '.') || ((string)(float)$protocol) !== $protocol
  ) {
    throw new Exception\InvalidArgumentException(Str\format(
      'The protocol string MUST contain only the HTTP version number (e.g., "1.1", "1.0").',
    ));
  }

  \header(
    Str\format('HTTP/%s %d%s', $protocol, $status, (
      !Str\is_empty($reason) ? ' '.$reason : ''
    )),
    true,
    $status,
  );
}
