namespace Nuxed\Configuration\Exception;

<<__Sealed(MissingConfigurationException::class, InvalidTypeException::class)>>
interface IException {
  require extends \Exception;
}
