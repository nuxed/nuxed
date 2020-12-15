namespace Nuxed\Process;

use namespace HH\Lib\{C, Str, Vec};

/**
 * Execute the given command, followed by the given arguments.
 *
 * @note: Arguments will be escaped.
 */
async function execute(string $command, string ...$args): Awaitable<Result> {
  $original_command = $command;
  $command .= ' ';
  $command .= $args
    |> Vec\map(
      $$,
      $arg ==> !C\contains(vec['|', '&'], $arg) ? \escapeshellarg($arg) : $arg,
    )
    |> Str\join($$, ' ');

  $spec = darray[
    1 => varray['pipe', 'w'],
    2 => varray['pipe', 'w'],
  ];
  $pipes = varray[];

  $proc = \proc_open($command, $spec, inout $pipes);
  invariant($proc, 'Failed to execute: %s', $command);

  $stdout = $pipes[1];
  $stderr = $pipes[2];
  \stream_set_blocking($stdout, false);

  $exit_code = -2;
  $output = '';
  while (true) {
    $chunk = \stream_get_contents($stdout);
    $output .= $chunk;
    $status = \proc_get_status($proc);
    if ($status['pid'] && !$status['running']) {
      $exit_code = $status['exitcode'];
      break;
    }
    /* HHAST_IGNORE_ERROR[DontAwaitInALoop] */
    await \stream_await($stdout, \STREAM_AWAIT_READ);
  }
  $output .= \stream_get_contents($stdout);
  \fclose($stdout);
  \fclose($stderr);

  // Always returns -1 if we called `proc_get_status` first
  \proc_close($proc);

  return new Result($original_command, $args, $exit_code, $output);
}
