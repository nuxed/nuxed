namespace Nuxed\Translation\Loader;

use namespace Nuxed\Translation;

interface ILoader {
  /**
   * Loads a resource.
   *
   * @throws Translation\Exception\NotFoundResourceException when the resource cannot be found
   * @throws Translation\Exception\InvalidResourceException  when the resource cannot be loaded
   */
  public function load(
    string $resource,
    string $locale,
    string $domain = 'messages',
  ): Awaitable<Translation\MessageCatalogue>;
}
