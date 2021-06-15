namespace Nuxed\Process\Exception;

use HH\Lib\Str;

<<__Sealed(FailedExecutionException::class, PossibleAttackException::class)>>
class RuntimeException extends \RuntimeException implements IException {
}
