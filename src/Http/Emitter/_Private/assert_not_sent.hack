/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http\Emitter\_Private;

use namespace Nuxed\Http\Exception;

/**
 * Checks to see if content has previously been sent.
 *
 * If either headers have been sent or the output buffer contains content,
 * raises an exception.
 *
 * @throws EmitterException if headers have already been sent.
 * @throws EmitterException if output is present in the output buffer.
 */
function assert_not_sent(): void {
  if (\headers_sent()) {
    throw new Exception\RuntimeException(
      'Unable to emit response; headers already sent',
    );
  }

  if (\ob_get_level() > 0 && \ob_get_length() > 0) {
    throw new Exception\RuntimeException(
      'Output has been emitted previously; cannot emit response',
    );
  }
}
