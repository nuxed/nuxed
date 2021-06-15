namespace Nuxed\Http\Message\_Private;

use namespace HH\Lib\{Regex, Str};
use namespace Nuxed\Http\{Exception, Message};

final class ProtocolVersionMarshaler {
  public function marshal(KeyedContainer<arraykey, mixed> $server): string {
    $protocol = (string)$server['SERVER_PROTOCOL'] ?? '1.1';
    if (
      !Regex\matches($protocol, re"#^(HTTP/)?(?P<version>[1-9]\d*(?:\.\d)?)$#")
    ) {
      throw new Exception\ServerException(
        Message\StatusCode::VERSION_NOT_SUPPORTED,
      );
    }

    $matches = Regex\first_match(
      $protocol,
      re"#^(HTTP/)?(?P<version>[1-9]\d*(?:\.\d)?)$#",
    ) as nonnull;

    return $matches['version'];
  }
}
