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

/**
* Inject the provided Content-Type, if none is already present.
*/
function inject_content_type_in_headers(
  string $contentType,
  KeyedContainer<string, Container<string>> $headers,
): KeyedContainer<string, Container<string>> {
  $headers = dict($headers);

  $hasContentType = C\reduce_with_key(
    $headers,
    ($carry, $key, $_item) ==>
      $carry ?: (Str\lowercase($key) === 'content-type'),
    false,
  );

  if (false === $hasContentType) {
    $headers['content-type'] = vec[
      $contentType,
    ];
  }

  return $headers;
}
