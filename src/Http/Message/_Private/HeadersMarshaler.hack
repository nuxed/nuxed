/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Http\Message\_Private;

use namespace HH\Lib\{C, Str};

final class HeadersMarshaler {
  public function marshal(
    KeyedContainer<arraykey, mixed> $server,
  ): KeyedContainer<string, Container<string>> {
    $headers = dict[];

    $valid = (mixed $value): bool ==>
      $value is Container<_> ? C\count($value) > 0 : ((string)$value) !== '';

    foreach ($server as $key => $value) {
      $key = (string)$key;
      // Apache prefixes environment variables with REDIRECT_
      // if they are added by rewrite rules
      if (Str\search($key, 'REDIRECT_') === 0) {
        $key = Str\slice($key, 9);
        // We will not overwrite existing variables with the
        // prefixed versions, though
        if (C\contains_key($server, $key)) {
          continue;
        }
      }

      if (!$valid($value)) {
        continue;
      }

      if (Str\search($key, 'HTTP_') === 0) {
        $name = (string)\strtr(Str\lowercase(Str\slice($key, 5)), '_', '-');

        if (!$value is Container<_>) {
          $value = vec[(string)$value];
        }

        $val = vec[];
        foreach ($value as $v) {
          $val[] = (string)$v;
        }

        $headers[$name] = $val;
        continue;
      }

      if (Str\search($key, 'CONTENT_') === 0) {
        $name = 'content-'.Str\lowercase(Str\slice($key, 8));
        if (!$value is Container<_>) {
          $value = vec[(string)$value];
        }
        $headers[$name] = vec[];
        foreach ($value as $v) {
          $headers[$name][] = (string)$v;
        }
        continue;
      }
    }

    return $headers;
  }
}
