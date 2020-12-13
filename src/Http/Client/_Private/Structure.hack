namespace Nuxed\Http\Client\_Private;

use namespace Nuxed\Http\Client;
final abstract class Structure {
  const type HttpClientOptions = Client\HttpClientOptions;

  public static function httpClientOptions(
  ): TypeStructure<this::HttpClientOptions> {
    return type_structure(static::class, 'HttpClientOptions');
  }
}
