namespace Nuxed\Cache\Store;

use namespace HH\Lib\{C, Str};
use namespace Nuxed\Cache\Exception;

trait StoreTrait {
  require implements IStore;

  private dict<string, string> $ids = dict[];

  <<__Memoize>>
  protected function getId(
    string $key,
    string $namespace,
    ?int $max_id_length = null,
  ): string {
    if (C\contains_key($this->ids, $key)) {
      return $namespace.$this->ids[$key];
    }

    if ('' === $key) {
      throw new Exception\InvalidArgumentException(
        'Cache key length must be greater than zero',
      );
    }

    foreach (vec['{', '}', '(', ')', '@', ':'] as $c) {
      if (Str\contains($key, $c)) {
        throw new Exception\InvalidArgumentException(Str\format(
          'Cache key "%s" contains reserved characters {}()@:',
          $key,
        ));
      }
    }

    $this->ids[$key] = $key;
    $id = $namespace.$key;
    if ($max_id_length is null || Str\length($id) < $max_id_length) {
      return $id;
    }

    // Use MD5 to favor speed over security, which is not an issue here
    $id = Str\splice(\base64_encode(\hash('md5', $key, true)), ':', -2);
    $this->ids[$key] = $id;
    $id = $namespace.$id;

    return $id;
  }
}
