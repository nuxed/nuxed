namespace Nuxed\Filesystem;

use namespace HH\Lib\{File, Str};

final class File extends Node {
  public function getReadHandle(): File\CloseableReadHandle {
    $this->isAvailable();
    $this->isReadable();

    try {
      return File\open_read_only($this->path->toString());
    } catch (\Exception $e) {
      throw new Exception\RuntimeException(
        Str\format(
          'Error while opening file (%s) for reading.',
          $this->path->toString(),
        ),
        $e->getCode(),
        $e,
      );
    }
  }

  public function getWriteHandle(
    File\WriteMode $mode = File\WriteMode::OPEN_OR_CREATE,
  ): File\CloseableWriteHandle {
    if ($mode === File\WriteMode::MUST_CREATE && $this->exists()) {
      throw new Exception\ExistingNodeException(Str\format(
        'Cannot re-create file (%s) for writing.',
        $this->path->toString(),
      ));
    }

    $creating = $mode === File\WriteMode::OPEN_OR_CREATE ||
      $mode === File\WriteMode::MUST_CREATE;
    if (!$creating && !$this->exists()) {
      throw new Exception\MissingNodeException(
        Str\format('File (%s) doesn\'t exist.', $this->path->toString()),
      );
    }

    if (
      (
        !$creating ||
        ($mode === File\WriteMode::OPEN_OR_CREATE && $this->exists())
      ) &&
      !$this->writable()
    ) {
      throw new Exception\UnwritableNodeException(
        Str\format('File (%s) is not writable.', $this->path->toString()),
      );
    }

    try {
      return File\open_write_only($this->path->toString(), $mode);
    } catch (\Exception $e) {
      throw new Exception\RuntimeException(
        Str\format(
          'Error while opening file (%s) for writing (mode:%s).',
          $this->path->toString(),
          $mode as string,
        ),
        $e->getCode(),
        $e,
      );
    }
  }

  public function getReadWriteHandle(
    File\WriteMode $mode = File\WriteMode::OPEN_OR_CREATE,
  ): File\CloseableReadWriteHandle {
    if ($mode === File\WriteMode::MUST_CREATE && $this->exists()) {
      throw new Exception\ExistingNodeException(Str\format(
        'Cannot re-create file (%s) for writing.',
        $this->path->toString(),
      ));
    }

    $creating = $mode === File\WriteMode::OPEN_OR_CREATE ||
      $mode === File\WriteMode::MUST_CREATE;
    if (!$creating && !$this->exists()) {
      throw new Exception\MissingNodeException(
        Str\format('File (%s) doesn\'t exist.', $this->path->toString()),
      );
    }

    if (
      (
        !$creating ||
        ($mode === File\WriteMode::OPEN_OR_CREATE && $this->exists())
      ) &&
      !$this->writable()
    ) {
      throw new Exception\UnwritableNodeException(
        Str\format('File (%s) is not writable.', $this->path->toString()),
      );
    }

    if ($this->exists()) {
      $this->isReadable();
    }

    try {
      return File\open_read_write($this->path()->toString(), $mode);
    } catch (\Exception $e) {
      throw new Exception\RuntimeException(
        Str\format(
          'Error while opening file (%s) for reading+writing (mode:%s).',
          $this->path->toString(),
          $mode as string,
        ),
        $e->getCode(),
        $e,
      );
    }
  }

  public static async function temporary(
    string $perfix,
    ?string $directory = null,
  ): Awaitable<File> {
    $directory ??= \sys_get_temp_dir() as string;
    $folder = new Folder($directory);
    if (!$folder->exists()) {
      await $folder->create();
    }

    $file = new self(\tempnam($directory, $perfix) as string);
    if (!$file->exists()) {
      // this shouldn't happen.
      await $file->create();
    }

    return $file;
  }

  /**
   * {@inheritdoc}
   */
  <<__Override>>
  public async function create(int $mode = 0755): Awaitable<bool> {
    if ($this->exists()) {
      throw new Exception\ExistingNodeException(
        Str\format('File (%s) already exists.', $this->path->toString()),
      );
    }

    $folder = $this->parent();

    if ($folder is null) {
      return false;
    }

    if (!$folder->exists()) {
      await $folder->create();
    }

    if ($folder->writable()) {
      $created = \touch($this->path->toString()) as bool;
      if ($created) {
        await $this->chmod($mode);
      }

      return $created;
    } else {
      throw new Exception\UnwritableNodeException(Str\format(
        'Parent Folder (%s) is not writable.',
        $folder->path()->toString(),
      ));
    }
  }

  /**
   * {@inheritdoc}
   */
  <<__Override>>
  public async function copy(
    string $target,
    OperationType $process = OperationType::OVERWRITE,
    int $mode = 0755,
  ): Awaitable<File> {
    $this->isAvailable();
    $target = Path::create($target);
    if ($target->exists() && $process !== OperationType::OVERWRITE) {
      throw new Exception\ExistingNodeException(
        'Cannot copy file as the target already exists.',
      );
    }

    if (\copy($this->path->toString(), $target->toString())) {
      $file = new File($target->toString());
      await $file->chmod($mode);

      return $file;
    }

    throw new Exception\RuntimeException(
      'An error occurred while performing the copy operation.',
    );
  }

  /**
   * Remove the file.
   */
  <<__Override>>
  public async function delete(): Awaitable<bool> {
    $this->isAvailable();
    $deleted = \unlink($this->path->toString());
    $this->reset();
    return $deleted;
  }

  /**
   * Return the file extension.
   */
  public function extension(): ?string {
    return $this->path->extension();
  }

  /**
   * Return an MD5 checksum of the file.
   */
  public function md5(bool $raw = false): string {
    $this->isAvailable();
    $this->isReadable();
    return \md5_file($this->path->toString(), $raw) as string;
  }

  /**
   * Return the mime type for the file.
   */
  public function mimeType(): string {
    $this->isAvailable();
    $info = \finfo_open(\FILEINFO_MIME_TYPE);
    $type = \finfo_file($info, $this->path->toString());
    \finfo_close($info);
    return $type as string;
  }

  /**
   * Reset the cache and path.
   */
  <<__Override>>
  public function reset(?string $path = null): this {
    if ($path is nonnull) {
      $path = Path::create($path);
      if ($path->exists() && $path->isFolder()) {
        throw new Exception\InvalidPathException(Str\format(
          'Invalid file path (%s), folders are not allowed.',
          $path->toString(),
        ));
      }

      return parent::reset($path->toString());
    }

    return parent::reset();
  }

  /**
   * Append data to the end of a file.
   */
  public async function append(string $data): Awaitable<void> {
    try {
      await $this->write($data, File\WriteMode::APPEND);
    } catch (\Exception $e) {
      throw new Exception\WriteErrorException(
        Str\format(
          'Error while appending data to file (%s).',
          $this->path->toString(),
        ),
        $e->getCode(),
        $e,
      );
    }
  }

  /**
   * Prepend data to the beginning of a file.
   */
  public async function prepend(string $data): Awaitable<void> {
    try {
      $content = await $this->read();
      await $this->write($data.$content);
    } catch (\Exception $e) {
      throw new Exception\WriteErrorException(
        Str\format(
          'Error while prepending data to file (%s).',
          $this->path->toString(),
        ),
        $e->getCode(),
        $e,
      );
    }
  }

  /**
   * Write data to a file (will erase any previous contents).
   */
  public async function write(
    string $data,
    File\WriteMode $mode = File\WriteMode::TRUNCATE,
  ): Awaitable<void> {
    try {
      $handle = $this->getWriteHandle($mode);

      try {
        using ($_lock = $handle->tryLockx(File\LockType::EXCLUSIVE)) {
          await $handle->writeAllAsync($data);
        }
      } catch (File\AlreadyLockedException $e) {
        using ($_lock = $handle->lock(File\LockType::EXCLUSIVE)) {
          await $handle->writeAllAsync($data);
        }
      } finally {
        $handle->close();
      }
    } catch (\Exception $e) {
      throw new Exception\WriteErrorException(
        Str\format(
          'Error while writing to file (%s).',
          $this->path->toString(),
        ),
        $e->getCode(),
        $e,
      );
    }
  }

  /**
   * Open a file for reading. If $length is provided, will only read up to that limit.
   */
  public async function read(?int $length = null): Awaitable<string> {
    try {
      $handle = $this->getReadHandle();
      try {
        using ($_lock = $handle->tryLockx(File\LockType::SHARED)) {
          return await $handle->readAsync($length);
        }
      } catch (File\AlreadyLockedException $e) {
        using ($_lock = $handle->lock(File\LockType::SHARED)) {
          return await $handle->readAsync($length);
        }
      } finally {
        $handle->close();
      }
    } catch (\Exception $e) {
      throw new Exception\ReadErrorException(
        Str\format(
          'Error while reading from file (%s).',
          $this->path->toString(),
        ),
        $e->getCode(),
        $e,
      );
    }
  }

  /**
   * Read until there is no more data to read.
   */
  public async function readAll(
    ?int $length = null,
    ?int $timeout = null,
  ): Awaitable<string> {
    try {
      $handle = $this->getReadHandle();
      try {
        using ($_lock = $handle->tryLockx(File\LockType::SHARED)) {
          return await $handle->readAllAsync($length, $timeout);
        }
      } catch (File\AlreadyLockedException $e) {
        using ($_lock = $handle->lock(File\LockType::SHARED)) {
          return await $handle->readAllAsync($length, $timeout);
        }
      } finally {
        $handle->close();
      }
    } catch (\Exception $e) {
      throw new Exception\ReadErrorException(
        Str\format(
          'Error while reading from file (%s).',
          $this->path->toString(),
        ),
        $e->getCode(),
        $e,
      );
    }
  }

  public async function lines(): Awaitable<Lines> {
    return await $this->read()
      |> Str\replace($$, "\r\n", "\n")
      |> Str\replace($$, "\r", "\n")
      |> Str\split($$, "\n")
      |> new Lines($$);
  }

  /**
   * Return the current file size.
   */
  <<__Override>>
  public async function size(): Awaitable<int> {
    $this->isAvailable();
    return \filesize($this->path->toString()) as int;
  }

  /**
   * Creates a symbolic link.
   */
  public async function symlink(string $target): Awaitable<File> {
    $this->isAvailable();
    $target = Path::create($target);
    if ($target->exists()) {
      throw new Exception\InvalidPathException(
        Str\format('Target (%s) already exists.', $target->toString()),
      );
    }

    $error_level = \error_reporting(0);
    \symlink($this->path->toString(), $target->toString());
    \error_reporting($error_level);
    if (!$target->exists() || !$target->isSymlink()) {
      throw new Exception\RuntimeException(Str\format(
        'Error while creating a symbolic link (%s) for file (%s).',
        $target->toString(),
        $this->path->toString(),
      ));
    }

    return new File($target->toString());
  }

  /**
   * Create a hard link.
   */
  public async function link(string $link): Awaitable<File> {
    $this->isAvailable();
    $link = Path::create($link);
    if ($link->exists()) {
      throw new Exception\InvalidPathException(
        Str\format('Link (%s) already exists.', $link->toString()),
      );
    }

    $error_level = \error_reporting(0);
    \link($this->path->toString(), $link->toString());
    \error_reporting($error_level);
    if (!$link->exists()) {
      throw new Exception\RuntimeException(Str\format(
        'Error while creating a hard link (%s) for file (%s).',
        $link->toString(),
        $this->path->toString(),
      ));
    }

    return new File($link->toString());
  }
}
