namespace Nuxed\Http\Message\Body;

use namespace HH\Lib\{File, IO};

function memory(string $content = ''): IO\SeekableReadWriteHandle {
  return new IO\MemoryHandle($content);
}

function temporary(): IO\SeekableReadWriteHandle {
  return File\open_read_write(
    \sys_get_temp_dir().'/'.\bin2hex(\random_bytes(8)),
    File\WriteMode::MUST_CREATE,
  );
}

function file(
  string $path,
  File\WriteMode $mode = File\WriteMode::OPEN_OR_CREATE,
): IO\SeekableReadWriteHandle {
  return File\open_read_write($path, $mode);
}
