/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http\Message\_Private;

use namespace HH\Lib\{C, IO, Str};
use namespace Nuxed\Http;

function has_cache_control_directive<T as IO\SeekableHandle>(
  Http\Message\IMessage<T> $message,
  string $directive,
): bool {
  if (!$message->hasHeader('cache-control')) {
    return false;
  }

  $directive = Str\lowercase($directive);
  return C\reduce(
    $message->getHeader('cache-control'),
    ($result, $value) ==> $result ||
      Str\lowercase($value) === $directive ||
      Str\starts_with(Str\lowercase($value), Str\format('%s=', $directive)),
    false,
  );
}

function get_cache_control_directive<T as IO\SeekableHandle>(
  Http\Message\IMessage<T> $message,
  string $directive,
): ?int {
  $directive = Str\lowercase($directive);
  foreach ($message->getHeader('cache-control') as $value) {
    if (Str\starts_with(Str\lowercase($value), Str\format('%s=', $directive))) {
      return (int)C\lastx(Str\split($value, '=', 2));
    }
  }

  return null;
}

function with_cache_control_directive<
  TH as IO\SeekableHandle,
  TM as Http\Message\IMessage<TH>,
>(TM $message, string $directive, ?int $seconds = null): TM {
  if (
    has_cache_control_directive($message, $directive) &&
    get_cache_control_directive($message, $directive) === $seconds
  ) {
    return $message;
  }

  return $message->withAddedHeader('cache-control', vec[
    Str\format(
      '%s%s%s',
      Str\lowercase($directive),
      $seconds is nonnull ? '=' : '',
      $seconds is nonnull ? (string)$seconds : '',
    ),
  ]);
}

function without_cache_control_directive<
  TH as IO\SeekableHandle,
  TM as Http\Message\IMessage<TH>,
>(TM $message, string $directive): TM {
  if (!has_cache_control_directive($message, $directive)) {
    return $message;
  }

  $directive = Str\lowercase($directive);
  $cacheControl = $message->getHeader('cache-control');
  $header = vec[];
  foreach ($cacheControl as $value) {
    if (
      Str\lowercase($value) !== $directive &&
      !Str\starts_with(Str\lowercase($value), Str\format('%s=', $directive))
    ) {
      $header[] = $value;
    }
  }

  return $message->withHeader('cache-control', $header);
}
