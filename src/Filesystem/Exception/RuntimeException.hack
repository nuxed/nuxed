namespace Nuxed\Filesystem\Exception;

<<__Sealed(
  ExistingNodeException::class,
  MissingNodeException::class,
  ReadErrorException::class,
  WriteErrorException::class,
  UnreadableNodeException::class,
  UnwritableNodeException::class,
)>>
class RuntimeException extends \RuntimeException implements IException {}
