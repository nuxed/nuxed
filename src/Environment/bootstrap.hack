namespace Nuxed\Environment;

use namespace Nuxed\Filesystem;

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
  Mode $defaultMode = Mode::DEVELOPMENT,
): Awaitable<void> {
  $path = Filesystem\Path::create($path);
  $dist = Filesystem\Path::create($path->toString().'.dist');
  if ($path->exists() || !$dist->exists()) {
    await load($path->toString());
  } else if ($dist->exists()) {
    await load($dist->toString());
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
    $mode = $defaultMode;
    put('APP_MODE', $mode);
  }

  $local = Filesystem\Path::create($path->toString().'.local');
  if ($mode !== Mode::TEST && $local->exists()) {
    await load($local->toString());
  }

  if (Mode::LOCAL === $mode) {
    return;
  }

  $modeSpecific = Filesystem\Path::create($path->toString().'.'.$mode);
  if ($modeSpecific->exists()) {
    await load($modeSpecific->toString());
  }

  if (Mode::TEST === $mode) {
    return;
  }

  $localModeSpecifc = Filesystem\Path::create(
    $modeSpecific->toString().'.local',
  );
  if ($localModeSpecifc->exists()) {
    await load($localModeSpecifc->toString());
  }
}
