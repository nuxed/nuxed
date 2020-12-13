namespace Nuxed\Translation\Loader;

use namespace HH;
use namespace Nuxed\Translation;

interface ILoader {
  abstract const type TFormat;

  /**
   * Loads a locale.
   *
   * @throws Translation\Exception\NotFoundResourceException when the resource cannot be found
   * @throws Translation\Exception\InvalidResourceException  when the resource cannot be loaded
   */
  public function load(
    this::TFormat $resource,
    string $locale,
    string $domain = 'messages',
  ): Awaitable<Translation\MessageCatalogue>;

  public function getFormat(): HH\TypeStructure<this::TFormat>;
}
