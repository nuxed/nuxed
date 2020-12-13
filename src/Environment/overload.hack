namespace Nuxed\Environment;

/**
 * Loads one or several .env files into the current environment
 * and enables override existing variables.
 */
async function overload(string ...$files): Awaitable<void> {
  $lastOperation = async {
  };
  foreach ($files as $file) {
    $lastOperation = async {
      await $lastOperation;
      await _Private\load($file, true);
    };
  }

  await $lastOperation;
}
