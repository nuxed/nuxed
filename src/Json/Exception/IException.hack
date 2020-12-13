namespace Nuxed\Json\Exception;

<<__Sealed(JsonDecodeException::class, JsonEncodeException::class)>>
interface IException {
  require extends \Exception;
}
