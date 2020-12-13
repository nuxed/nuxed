namespace Nuxed\Process\Exception;

use namespace HH\Lib\Str;
use namespace Nuxed\Process;

final class SubprocessException
  extends \RuntimeException
  implements IException {

  public function __construct(private Process\Result $result) {
    parent::__construct(Str\format(
      'Command "%s %s" failed with exit code %d',
      $result->getCommand(),
      Str\join($result->getArguments(), ' '),
      $result->getExitCode(),
    ));
  }

  public function getResult(): Process\Result {
    return $this->result;
  }
}
