namespace Nuxed\Log\Handler;

use namespace HH\Lib\Str;
use namespace Nuxed\{Filesystem, Log};
use namespace Nuxed\Log\{Exception, Formatter};

final class FileHandler extends AbstractHandler {
  /**
   * @param Log\LogLevel   $level  The minimum logging level at which this handler will be triggered
   * @param bool       $bubble Whether the messages that are handled can bubble up the stack or not
   */
  public function __construct(
    private Filesystem\File $file,
    ?Formatter\IFormatter $formatter = null,
    Log\LogLevel $level = Log\LogLevel::DEBUG,
    bool $bubble = true,
  ) {
    parent::__construct($formatter, $level, $bubble);
  }

  /**
   * Writes the messenge down to the log of the implementing handler
   */
  <<__Override>>
  protected async function write(string $message): Awaitable<void> {
    try {
      if (!$this->file->exists()) {
        await $this->file->create(0644);
      }

      await $this->file->append($message);
    } catch (Filesystem\Exception\IException $exception) {
      throw new Exception\RuntimeException(
        Str\format(
          'Error writing log message to %s.',
          $this->file->path()->toString(),
        ),
        $exception->getCode(),
        $exception,
      );
    }
  }
}
