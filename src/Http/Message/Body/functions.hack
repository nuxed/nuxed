namespace Nuxed\Http\Message\Body;

use namespace HH\Lib\{File, IO};

function memory(string $content = ''): IO\SeekableReadWriteHandle {
  return new IO\MemoryHandle($content);
}

function file(
  string $path,
  File\WriteMode $mode = File\WriteMode::OPEN_OR_CREATE,
): IO\SeekableReadWriteHandle {
  return File\open_read_write($path, $mode);
}
