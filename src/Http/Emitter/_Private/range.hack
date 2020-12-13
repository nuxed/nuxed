namespace Nuxed\Http\Emitter\_Private;

use namespace HH\Lib\Regex;

type ContentRange = shape(
  'unit' => string,
  'first' => int,
  'last' => int,
  'length' => ?int,
);

function range(string $header): ?ContentRange {
  $pattern =
    re"/(?P<unit>[\w]+)\s+(?P<first>\d+)-(?P<last>\d+)\/(?P<length>\d+|\*)/";

  if (!Regex\matches($header, $pattern)) {
    return null;
  }

  $matches = Regex\first_match($header, $pattern) as nonnull;
  return shape(
    'unit' => $matches['unit'],
    'first' => (int)$matches['first'],
    'last' => (int)$matches['last'],
    'length' => $matches['length'] === '*' ? null : (int)$matches['length'],
  );
}
