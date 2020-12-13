namespace Nuxed\Http\Emitter\_Private;

use namespace HH\Lib\{IO, Str};

/**
 * Copies content from the given $source read handle to the $target write handle
 * until the eol of $source is reached.
 *
 * If `$max_bytes` is `null`, there is no limit on the chunk size - this function will
 * copy the content of $source all at once.
 */
async function copy(
  IO\SeekableReadHandle $source,
  IO\WriteHandle $target,
  ?int $max_bytes = null,
  ?int $timeout_ns = null,
  int $iteration = 0,
): Awaitable<bool> {
  if ($iteration === 0) {
    $source->seek(0);
  }

  $iteration++;
  $content = await $source->readAsync($max_bytes, $timeout_ns);
  if ('' !== $content) {
    await $target->writeAsync($content, $timeout_ns);
    await copy($source, $target, $max_bytes, $timeout_ns, $iteration);
  }

  return true;
}

async function copy_range(
  IO\SeekableReadHandle $source,
  IO\WriteHandle $target,
  int $length,
  int $remaining,
  ?int $timeout_ns = null,
): Awaitable<int> {
  if ($remaining >= $length) {
    $contents = await $source->readAsync($length, $timeout_ns);
    if ('' !== $contents) {
      $remaining -= Str\length($contents);
      await $target->writeAsync($contents);
      await copy_range($source, $target, $length, $remaining, $timeout_ns);
    }
  }

  return $remaining;
}
