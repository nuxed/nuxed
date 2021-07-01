/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http\Message\_Private;

use namespace HH\Lib\{IO, Str};
use namespace Nuxed\Http;
use namespace Nuxed\Http\Exception;

function get_date_header<
  Th as IO\SeekableHandle,
  Tm as Http\Message\IMessage<Th>,
>(Tm $message, string $header): ?int {
  if (!$message->hasHeader($header)) {
    return null;
  }

  $value = $message->getHeaderLine($header);
  $date = \DateTime::createFromFormat(\DATE_RFC2822, $value);
  if (!$date is \DateTimeInterface) {
    throw new Exception\RuntimeException(
      Str\format('The %s HTTP header is not parseable (%s).', $header, $value),
    );
  }

  return (int)$date->format('U');
}

function with_date_header<
  Th as IO\SeekableHandle,
  Tm as Http\Message\IMessage<Th>,
>(Tm $message, string $header, ?int $date = null): Tm {
  if ($date is null) {
    return $message->withoutHeader($header);
  }

  $date = \DateTimeImmutable::createFromFormat(
    'U',
    Str\format('%d', $date),
    new \DateTimeZone('UTC'),
  );

  return $message->withHeader($header, vec[
    $date->format('D, d M Y H:i:s').' GMT',
  ]);
}
