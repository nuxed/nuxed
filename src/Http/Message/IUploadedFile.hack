namespace Nuxed\Http\Message;

use namespace HH\Lib\File;

/**
 * Value object representing a file uploaded through an HTTP request.
 *
 * Instances of this interface are considered immutable; all methods that
 * might change state MUST be implemented such that they retain the internal
 * state of the current instance and return an instance that contains the
 * changed state.
 */
interface IUploadedFile {
  /**
   * Retrieve a stream representing the uploaded file.
   *
   * This method MUST return a File\ReadHandle instance, representing the
   * uploaded file. The purpose of this method is to allow utilizing native Hack
   * file functionality to manipulate the file upload.
   *
   * If the move() method has been called previously, this method MUST raise
   * an exception.
   *
   * @throws Exception\IException in cases when no stream is available or can be
   *     created.
   */
  public function getHandle(): File\CloseableReadHandle;

  /**
   * Move the uploaded file to a new location.
   *
   * This method is guaranteed to work in both SAPI and non-SAPI environments.
   *
   * Implementations must determine which environment they are in, and use the
   * appropriate method to perform the operation.
   *
   * $targetPath may be an absolute path, or a relative path. If it is a
   * relative path, resolution should be the same as used by Hack's File\open_*()
   * functions.
   *
   * The original file or handle MUST be removed on completion.
   *
   * If this method is called more than once, any subsequent calls MUST raise
   * an exception.
   *
   * If you wish to move to a handle, use getHandle(), as SAPI operations
   * cannot guarantee writing to stream destinations.
   *
   * @throws Exception\IException if the $targetPath specified is invalid.
   * @throws Exception\IException on any error during the move operation, or on
   *     the second or subsequent call to the method.
   */
  public function move(string $targetPath): Awaitable<void>;

  /**
   * Retrieve the file size in bytes.
   *
   * Implementations SHOULD calculates this based on the actual size transmitted.
   */
  public function getSize(): ?int;

  /**
   * Retrieve the error associated with the uploaded file.
   *
   * If the file was uploaded successfully, this method MUST return
   * UploadFileError::None.
   */
  public function getError(): UploadedFileError;

  /**
   * Retrieve the filename sent by the client.
   *
   * Do not trust the value returned by this method. A client could send
   * a malicious filename with the intention to corrupt or hack your
   * application.
   *
   * @return string|null The filename sent by the client or null if none
   *     was provided.
   */
  public function getClientFilename(): ?string;

  /**
   * Retrieve the media type sent by the client.
   *
   * Do not trust the value returned by this method. A client could send
   * a malicious media type with the intention to corrupt or hack your
   * application.
   *
   * @return string|null The media type sent by the client or null if none
   *     was provided.
   */
  public function getClientMediaType(): ?string;
}
