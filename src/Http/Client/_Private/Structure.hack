/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Client\_Private;

use namespace Nuxed\Http\Client;
final abstract class Structure {
  const type HttpClientOptions = Client\HttpClientOptions;

  public static function httpClientOptions(
  ): TypeStructure<this::HttpClientOptions> {
    return type_structure(static::class, 'HttpClientOptions');
  }
}
