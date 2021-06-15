namespace Nuxed\Environment;

use namespace HH\Lib\Filesystem;
use namespace HH\Lib\File;
use namespace HH\Lib\OS;

use function file_exists;

/**
 * Bootstrap your environment.
 *
 * Loads a .env file and the corresponding .env.local, .env.$mode and .env.$mode.local files if they exist.
 *
 * .env.local is always ignored in test env because tests should produce the same results for everyone.
 * .env.dist is loaded when it exists and .env is not found.
 *
 * @param string  $path         A file to load
 * @param Mode    $defaultMode  The app mode to use when none is defined
 */
async function bootstrap(
  string $path,
  Mode $default_mode = Mode::DEVELOPMENT,
): Awaitable<void> {
  $dist = $path.'.dist';
  if (file_exists($path) || !file_exists($dist)) {
    await load($path);
  } else if (file_exists($dist)) {
    await load($dist);
  }

  try {
    $mode = mode();
  } catch (Exception\RuntimeException $exception) {
    // Runtime exception can be thrown for two reasons:
    // 1. the "APP_MODE" variable is missing
    // 2. it contains an invalid value.
    // in case it contains an invalid value, we throw the exception again.
    if (
      $exception->getCode() !== Exception\RuntimeException::MissingModeVariable
    ) {
      throw $exception;
    }

    // otherwise, we relay on the default mode provided.
    $mode = $default_mode;
    put('APP_MODE', $mode);
  }

  $local = $path.'.local';
  if ($mode !== Mode::TEST && file_exists($local)) {
    await load($local);
  }

  if (Mode::LOCAL === $mode) {
    return;
  }

  $mode_specific = $path.'.'.$mode;
  if (file_exists($mode_specific)) {
    await load($mode_specific);
  }

  if (Mode::TEST === $mode) {
    return;
  }

  $local_mode_specifc = $mode_specific.'.local';
  if (file_exists($local_mode_specifc)) {
    await load($local_mode_specifc);
  }
}
