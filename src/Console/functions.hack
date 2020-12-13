namespace Nuxed\Console;

use namespace HH;
use namespace HH\Lib\{C, Vec};

function input(bool $strict = false): Input\IInput {
  return new Input\Input(argv(), Terminal::getInputHandle(), $strict);
}

function output(
  Output\Verbosity $verbosity = Output\Verbosity::NORMAL,
  ?Formatter\IFormatter $formatter = null,
): Output\IOutput {
  $output = Terminal::getOutputHandle();
  $error = Terminal::getErrorHandle();
  if ($error is null) {
    return new Output\Output($output, $verbosity, $formatter);
  }

  return new Output\ConsoleOutput($output, $error, $verbosity, $formatter);
}

function argv(): vec<string> {
  $argv = HH\global_get('argv') as Traversable<_>;
  $arguments = vec[];
  foreach ($argv as $argument) {
    $arguments[] = $argument as string;
  }

  return Vec\drop<string>($arguments, 1);
}

function argc(): int {
  return C\count(argv());
}
