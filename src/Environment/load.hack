namespace Nuxed\Environment;

/**
 * Loads one or several .env files into the current environment.
 */
async function load(string ...$files): Awaitable<void> {
  $lastOperation = async {
  };
  foreach ($files as $file) {
    $lastOperation = async {
      await $lastOperation;
      await _Private\load($file, false);
    };
  }

  await $lastOperation;
}
