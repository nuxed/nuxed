namespace Nuxed\Http\Emitter;

use namespace HH\Lib\C;
use namespace Nuxed\Http\Message;

function cookies(KeyedContainer<string, Message\ICookie> $cookies): void {
  $values = vec[];
  foreach ($cookies as $name => $cookie) {
    $values[] = _Private\cookie_header($name, $cookie);
  }

  if (0 === C\count($values)) {
    return;
  }

  headers(dict['Set-Cookie' => $values]);
}
