namespace Nuxed\Asset\VersionStrategy;

/**
 * Disable version for all assets.
 */
final class EmptyVersionStrategy implements IVersionStrategy {
  /**
   * {@inheritdoc}
   */
  public async function getVersion(string $_asset): Awaitable<string> {
    return '';
  }

  /**
   * {@inheritdoc}
   */
  public async function applyVersion(string $path): Awaitable<string> {
    return $path;
  }
}
