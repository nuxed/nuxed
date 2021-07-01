/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Message;

use namespace HH\Lib\File;
use namespace Nuxed\Http\{Exception, Message};

/**
 * Value object representing a file uploaded through an HTTP request.
 */
final class UploadedFile implements Message\IUploadedFile {
  private bool $moved = false;
  private ?File\CloseableReadHandle $handle;

  public function __construct(
    private string $file,
    private ?int $size,
    private Message\UploadedFileError $error,
    private ?string $clientFilename = null,
    private ?string $clientMediaType = null,
  ) {}

  /**
   * Retrieve a handle representing the uploaded file.
   *
   * This method will return a File\CloseableReadHandle instance, representing
   * the uploaded file. The purpose of this method is to allow utilizing native
   * Hack handles.
   *
   * If the move() method has been called previously, this method will raise
   * an exception.
   */
  public function getHandle(): File\CloseableReadHandle {
    if ($this->moved) {
      throw new Exception\UploadedFileAlreadyMovedException(
        'Cannot retrieve file handle after it has already moved.',
      );
    }

    if (!$this->isOk()) {
      throw new Exception\UploadedFileErrorException(
        'Cannot retrieve handle due to upload error.',
      );
    }

    if ($this->handle is nonnull) {
      return $this->handle;
    }

    $this->handle = File\open_read_only($this->file);
    return $this->handle;
  }

  /**
   * Move the uploaded file to a new location.
   *
   * This method is guaranteed to work in both SAPI and non-SAPI environments.
   *
   * $targetPath may be an absolute path, or a relative path. If it is a
   * relative path, resolution should be the same as used by Hack's File\open*()
   * functions.
   *
   * The original file will be removed on completion.
   *
   * If this method is called more than once, any subsequent calls will raise
   * an exception.
   */
  public async function move(string $targetPath): Awaitable<void> {
    $this->validateActive();

    if ('' === $targetPath) {
      throw new Exception\InvalidArgumentException(
        'Invalid path provided for move operation; must be a non-empty string.',
      );
    }

    $handle = $this->getHandle();
    $handle->seek(0);

    $target = File\open_write_only($targetPath, File\WriteMode::OPEN_OR_CREATE);
    using ($_lock = $target->tryLockx(File\LockType::EXCLUSIVE)) {
      await _Private\IO\copy($handle, $target);
    }

    $handle->close();
    $target->close();

    $this->moved = true;
  }

  /**
   * Retrieve the file size.
   */
  public function getSize(): ?int {
    return $this->size;
  }

  /**
   * Retrieve the error associated with the uploaded file.
   */
  public function getError(): Message\UploadedFileError {
    return $this->error;
  }

  /**
   * Retrieve the filename sent by the client.
   *
   * Do not trust the value returned by this method. A client could send
   * a malicious filename with the intention to corrupt or hack your
   * application.
   */
  public function getClientFilename(): ?string {
    return $this->clientFilename;
  }

  /**
   * Retrieve the media type sent by the client.
   *
   * Do not trust the value returned by this method. A client could send
   * a malicious media type with the intention to corrupt or hack your
   * application.
   */
  public function getClientMediaType(): ?string {
    return $this->clientMediaType;
  }

  /**
   * @return bool return true if there is no upload error
   */
  private function isOk(): bool {
    return Message\UploadedFileError::NONE === $this->error;
  }

  /**
   * @throws Exception\IException if is moved or not ok
   */
  private function validateActive(): void {
    if (false === $this->isOk()) {
      throw new Exception\UploadedFileErrorException(
        'Cannot retrieve handle due to upload error.',
      );
    }

    if ($this->moved) {
      throw new Exception\UploadedFileAlreadyMovedException();
    }
  }
}
