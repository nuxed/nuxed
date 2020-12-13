namespace Nuxed\Console\_Private;

async function execute(string $command): Awaitable<?string> {
  $descriptorSpec = darray[
    1 => varray['pipe', 'w'],
    2 => varray['pipe', 'w'],
  ];
  $pipes = vec[];
  $process = \proc_open(
    $command,
    $descriptorSpec,
    inout $pipes,
    null,
    null,
    dict['suppress_errors' => true],
  );
  if (!$process is resource) {
    return null;
  }

  invariant($process, 'Failed to execute: %s', $command);

  $stdout = $pipes[1];
  $stderr = $pipes[2];
  \stream_set_blocking($stdout, false);

  $exit_code = -2;
  $output = '';
  while (true) {
    $chunk = \stream_get_contents($stdout);
    $output .= $chunk;
    $status = \proc_get_status($process);
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
  \proc_close($process);

  if (0 !== $exit_code) {
    return null;
  }

  return $output;
}
