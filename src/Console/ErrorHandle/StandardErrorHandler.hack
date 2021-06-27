namespace Nuxed\Console\ErrorHandler;

use namespace Nuxed\Console\{Command, Exception, Input, Output, Style};
use namespace HH;
use namespace HH\Lib\{C, Str, Vec};

final class StandardErrorHandler implements IErrorHandler {
  /**
   * Handle the given error and return the proper exit code.
   */
  public async function handle(
    Input\IInput $input,
    Output\IOutput $output,
    \Throwable $exception,
    ?Command\Command $_command = null,
  ): Awaitable<int> {
    if ($output is Output\IConsoleOutput) {
      $output = $output->getErrorOutput();
    }

    $io = new Style\Style($input, $output);
    await $this->renderMessage($io, $exception);
    await $this->renderSource($io, $exception);
    await $this->renderTrace($io, $exception);

    $code = $exception->getCode() as arraykey;
    if ($code is string) {
      $code = Str\to_int($code) ?? Command\ExitCode::FAILURE;
    } else {
      $code as int;
    }

    if ($code > Command\ExitCode::EXIT_STATUS_OUT_OF_RANGE) {
      $code = $code % (Command\ExitCode::EXIT_STATUS_OUT_OF_RANGE + 1);
    }

    return $code;
  }

  private async function renderMessage(
    Style\IOutputStyle $io,
    \Throwable $exception,
  ): Awaitable<void> {
    $type = null;
    if (!$exception is Exception\Exception) {
      $type = \get_class($exception);
    }

    await $io->block(
      $exception->getMessage(),
      Output\Verbosity::NORMAL,
      $type,
      'fg=white; bg=red;',
      ' | ',
      true,
      true,
      false,
    );
  }

  private async function renderSource(
    Style\IOutputStyle $io,
    \Throwable $exception,
  ): Awaitable<void> {
    await $io->writeln(
      Str\format(
        '- %s:%d%s',
        $exception->getFile(),
        $exception->getLine(),
        Output\IOutput::EndOfLine,
      ),
      Output\Verbosity::VERBOSE,
    );
  }

  private async function renderTrace(
    Style\IOutputStyle $io,
    \Throwable $exception,
  ): Awaitable<void> {
    $lastOperation = async {
    };

    $frames = Vec\filter<dict<string, string>, _>(
      Vec\map<dict<string, string>, dict<string, string>, _>(
        /* HH_IGNORE_ERROR[4110] */
        $exception->getTrace(),
        (dict<string, string> $frame)[]: dict<string, string> ==> {
          unset($frame['args']);
          return dict<string, string>($frame);
        },
      ),
      (dict<string, string> $frame)[]: bool ==>
        C\contains_key<string, string, string>($frame, 'function') &&
        C\contains_key<string, string, string>($frame, 'file'),
    );

    if (0 !== C\count($frames)) {
      $lastOperation = async {
        await $io->writeln(
          '<fg=yellow>Exception trace: </>'.Output\IOutput::EndOfLine,
          Output\Verbosity::VERY_VERBOSE,
        );
      };

      foreach ($frames as $frame) {
        if (C\contains_key<string, string, string>($frame, 'class')) {
          $call = Str\format(
            ' %s%s%s()',
            $frame['class'],
            $frame['type'],
            $frame['function'],
          );
        } else {
          $call = Str\format(' %s()', $frame['function']);
        }

        $lastOperation = async {
          await $lastOperation;
          await $io
            ->writeln($call, Output\Verbosity::VERY_VERBOSE);
          await $io
            ->write(
              Str\format(
                ' ↪ <fg=green>%s</>%s%s',
                $frame['file'].
                (
                  C\contains_key<string, string, string>($frame, 'line')
                    ? ':'.$frame['line']
                    : ''
                ),
                Output\IOutput::EndOfLine,
                Output\IOutput::EndOfLine,
              ),
              Output\Verbosity::VERY_VERBOSE,
            );
        };
      }
    }

    await $lastOperation;
  }
}
