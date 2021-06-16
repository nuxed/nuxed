namespace Nuxed\Process;

use namespace HH\Lib\{Str, Vec};

async function execute(
  string $command,
  Container<string> $arguments = vec[],
  ?string $working_directory = null,
  KeyedContainer<string, string> $environment = dict[],
  bool $escape = true,
): Awaitable<(string, string)> {
  if ($escape) {
    $command = escape_command($command);
    $arguments = Vec\map(
      $arguments,
      (string $argument): string ==> escape_argument($argument),
    );
  } else {
    $arguments = vec<string>($arguments);
  }

  $commandline = Str\join(Vec\concat(vec[$command], $arguments), ' ');

  if (Str\contains($commandline, "\0")) {
    throw new Exception\PossibleAttackException('NULL byte detected.');
  }

  $working_directory = $working_directory ?? \getcwd();
  if (!\is_dir($working_directory)) {
    throw new Exception\RuntimeException('$working_directory does not exist.');
  }

  $pipes = varray[];
  $descriptor = darray[
    1 => varray['pipe', 'w'],
    2 => varray['pipe', 'w'],
  ];

  $proc = \proc_open(
    $commandline,
    $descriptor,
    inout $pipes,
    $working_directory,
    $environment,
  );

  if (!\is_resource($proc)) {
    throw new Exception\RuntimeException('Failed to open a new process.');
  }

  $stdout = $pipes[1];
  $stderr = $pipes[2];

  $exit_code = -2;
  $stdout_content = '';
  $stderr_content = '';

  while (true) {
    $stdout_content .= \stream_get_contents($stdout);
    $stderr_content .= \stream_get_contents($stderr);
    $status = \proc_get_status($proc);
    if ($status['pid'] && !$status['running']) {
      $exit_code = (int)$status['exitcode'];
      break;
    }

    /* HHAST_IGNORE_ERROR[DontAwaitInALoop] */
    await \stream_await($stdout, \STREAM_AWAIT_READ);
    /* HHAST_IGNORE_ERROR[DontAwaitInALoop] */
    await \stream_await($stderr, \STREAM_AWAIT_READ);
  }

  $stdout_content .= \stream_get_contents($stdout) as string;
  $stderr_content .= \stream_get_contents($stderr) as string;

  \fclose($stdout);
  \fclose($stderr);
  \proc_close($proc);

  if ($exit_code !== 0) {
    throw new Exception\FailedExecutionException(
      $commandline,
      $exit_code,
      $stdout_content,
      $stderr_content,
    );
  }

  return tuple($stdout_content, $stderr_content);
}
