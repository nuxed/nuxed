/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



namespace Nuxed\Environment;

use namespace HH\Lib\Str;

enum Mode: string as string {
  /**
   * The application is running in dev environment.
   */
  DEVELOPMENT = 'dev';

  /**
   * The application is running in production.
   */
  PRODUCTION = 'prod';

  /**
   * The application is running tests.
   */
  TEST = 'test';

  /**
   * The application is running in a local environment.
   */
  LOCAL = 'local';
}

/**
 * Retrieve the current applications mode based on the `APP_MODE` environment
 * variable.
 */
function mode(): Mode {
  if (!contains('APP_MODE')) {
    throw new Exception\RuntimeException(
      'Failed to determine application mode: "APP_MODE" variable is missing.',
      Exception\RuntimeException::MissingModeVariable,
    );
  }

  $mode = get('APP_MODE') as nonnull |> Str\lowercase($$);
  $modes = Mode::getNames();

  foreach ($modes as $value => $_) {
    $name = (string)$value;
    if ($mode === $name || Str\starts_with($mode, $name)) {
      return $value;
    }
  }

  throw new Exception\RuntimeException(
    Str\format(
      'Failed to determine application mode: invalid value for "APP_MODE" environment variable ( excepted "dev", "prod", "test", or "local", got "%s")',
      $mode,
    ),
    Exception\RuntimeException::InvalidModeValue,
  );
}
