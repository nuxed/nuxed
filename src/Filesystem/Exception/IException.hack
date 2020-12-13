namespace Nuxed\Filesystem\Exception;

<<__Sealed(
  RuntimeException::class,
  InvalidArgumentException::class,
  OutOfRangeException::class,
)>>
interface IException {
  require extends \Exception;
}
