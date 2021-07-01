/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Console;

use namespace HH;
use namespace HH\Lib\{C, Vec};

function input(): Input\IInput {
  return new Input\Input(argv(), Terminal::getInputHandle());
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
