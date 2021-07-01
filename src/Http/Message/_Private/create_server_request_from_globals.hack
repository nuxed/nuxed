/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Message\_Private;

use namespace HH;
use namespace HH\Lib\{C, Dict, IO, Str};
use namespace Nuxed\Http;
use namespace Nuxed\Http\Message;
use namespace AzJezz\HttpNormalizer;

async function create_server_request_from_globals(
): Awaitable<Message\ServerRequest> {
  $server = HH\global_get('_SERVER') as KeyedContainer<_, _>;
  $uploads = HttpNormalizer\normalize_files(
    HH\global_get('_FILES') as KeyedContainer<_, _>,
  );
  $cookies = HttpNormalizer\normalize(
    HH\global_get('_COOKIE') as KeyedContainer<_, _>,
  );
  $protocol = (new ProtocolVersionMarshaler())->marshal($server);
  $headers = (new HeadersMarshaler())->marshal($server);
  $uri = (new UriMarshaler())->marshal($server, $headers);
  $query = HttpNormalizer\parse($uri->getQuery() ?? '');
  $server = HttpNormalizer\normalize($server);
  $method = Message\HttpMethod::assert(
    Str\uppercase(($server['REQUEST_METHOD'] ?? 'GET') as string),
  );
  $ct = (string $value): bool ==>
    C\contains<string, string>($headers['content-type'] ?? vec[], $value);

  if (
    Message\HttpMethod::POST === $method &&
    ($ct('application/x-www-form-urlencoded') || $ct('multipart/form-data'))
  ) {
    $post = HH\global_get('_POST') as KeyedContainer<_, _>;
    $parsed = HttpNormalizer\normalize($post);
  } else {
    $parsed = null;
  }

  $uploads = Dict\map(
    $uploads,
    ($value) ==> {
      $errno = $value['error'];
      if ($errno > 5) {
        $errno--;
      }

      $error = Http\Message\UploadedFileError::assert($errno);
      return new Message\UploadedFile(
        $value['tmp_name'],
        $value['size'],
        $error,
        $value['name'] ?? null,
        $value['type'] ?? null,
      );
    },
  );

  $input = IO\request_input();
  $body = Message\Body\memory();
  await namespace\IO\copy($input, $body);

  return new Message\ServerRequest(
    $method,
    $uri,
    $headers,
    $body,
    $protocol,
    $server,
  )
    |> $$->withCookieParams($cookies)
    |> $$->withQueryParams($query)
    |> $parsed is nonnull ? $$->withParsedBody($parsed) : $$
    |> $$->withUploadedFiles($uploads);
}
