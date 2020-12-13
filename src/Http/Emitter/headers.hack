namespace Nuxed\Http\Emitter;

use namespace HH\Lib\Str;

/**
 * Emit response headers.
 *
 * Loops through each header, emitting each; the header value
 * is a set with multiple values; ensures that each is sent
 * in such a way as to create aggregate headers (instead of replace
 * the previous).
 */
function headers(KeyedContainer<string, Container<string>> $headers): void {
  foreach ($headers as $header => $values) {
    $name = Str\replace($header, '-', ' ')
      |> Str\capitalize_words($$)
      |> Str\replace($$, ' ', '-');

    $replace = $name === 'Set-Cookie' ? false : true;
    foreach ($values as $value) {
      \header(Str\format('%s: %s', $name, $value), $replace);
      $replace = false;
    }
  }
}
