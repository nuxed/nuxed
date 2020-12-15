namespace Nuxed\Log\_Private;

use namespace HH\Lib\Str;

function stringify(mixed $value): string {
  if ($value is bool) {
    return $value ? 'bool(true)' : 'bool(false)';
  }

  if ($value is string) {
    return Str\format('string("%s")', Str\replace($value, '"', '\"'));
  }

  if ($value is num) {
    if ($value is int) {
      return Str\format('int(%d)', $value);
    }

    return Str\format('float(%s)', Str\format_number($value, 1));
  }

  if ($value is resource) {
    return 'resource('.\get_resource_type($value).')';
  }

  if ($value is null) {
    return 'null';
  }

  if (\is_object($value) && !$value is Container<_>) {
    if ($value is \Throwable) {
      return \get_class($value).
        '('.
        'message='.
        stringify($value->getMessage()).
        ', code='.
        stringify($value->getCode()).
        ', file='.
        stringify($value->getFile()).
        ', line='.
        stringify($value->getLine()).
        ', trace= '.
        stringify($value->getTrace()).
        ', previous='.
        stringify($value->getPrevious()).
        ')';
    }

    if ($value is \DateTimeInterface) {
      return \get_class($value).'('.$value->format('Y-m-d\TH:i:s.uP').')';
    }

    return 'object('.\get_class($value).')';
  }

  if ($value is KeyedContainer<_, _>) {
    $result = 'KeyedContainer<_, _>(';
    foreach ($value as $key => $value) {
      $result .= Str\format('%s => %s, ', stringify($key), stringify($value));
    }

    $result = Str\ends_with($result, ', ')
      ? Str\strip_suffix($result, ', ')
      : $result;

    return $result.')';
  }

  if ($value is Container<_>) {
    $result = 'Container<_>(';
    foreach ($value as $value) {
      $result .= Str\format('%s, ', stringify($value));
    }

    $result = Str\ends_with($result, ', ')
      ? Str\strip_suffix($result, ', ')
      : $result;

    return $result.')';
  }

  return Str\format('unknown()');
}
