namespace Nuxed\Http\Message\_Private\IO;

use namespace HH\Lib\IO;

/**
 * Copies content from the given $source read handle to the $target write handle
 * until the eol of $source is reached.
 *
 * If `$max_bytes` is `null`, there is no limit on the chunk size - this function will
 * copy the content of $source all at once.
 */
async function copy(
  IO\ReadHandle $source,
  IO\WriteHandle $target,
  ?int $max_bytes = null,
  ?int $timeout_ns = null,
  int $iteration = 0,
): Awaitable<bool> {
  if ($iteration === 0 && $source is IO\SeekableReadHandle) {
    $source->seek(0);
  }

  $iteration++;
  $content = await $source->readAllAsync($max_bytes, $timeout_ns);
  if ('' !== $content) {
    await $target->writeAllAsync($content, $timeout_ns);
    await copy($source, $target, $max_bytes, $timeout_ns, $iteration);
  }

  return true;
}
