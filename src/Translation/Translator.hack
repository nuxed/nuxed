namespace Nuxed\Translation;

use namespace HH\Lib\{C, Regex, Str, Vec};
use namespace Facebook\TypeAssert;

final class Translator implements ITranslator, ILocaleAware, ITranslatorBag {
  private dict<string, MessageCatalogue> $catalogues = dict[];

  private ?string $locale;

  private vec<string> $fallbackLocales = vec[];

  private dict<string, Loader\ILoader> $loaders = dict[];

  private ?vec<string> $parentLocales;

  private dict<string, vec<(string, mixed, string)>> $resources = dict[];

  private Formatter\IMessageFormatter $formatter;

  /**
   * @throws Exception\InvalidArgumentException If a locale contains invalid characters
   */
  public function __construct(
    ?string $locale = null,
    ?Formatter\IMessageFormatter $_formatter = null,
  ) {
    $this->formatter = new Formatter\MessageFormatter();
    $this->setLocale($locale ?? \Locale::getDefault());
  }

  /**
   * Adds a Loader.
   */
  public function addLoader(string $format, Loader\ILoader $loader): void {
    $this->loaders[$format] = $loader;
  }

  /**
   * Adds a Resource.
   *
   * @throws InvalidArgumentException If the locale contains invalid characters
   */
  public function addResource<T>(
    string $format,
    T $resource,
    string $locale,
    ?string $domain = null,
  ): void {
    if ($domain is null) {
      $domain = 'messages';
    }

    $this->assertValidLocale($locale);
    if (!C\contains_key($this->resources, $locale)) {
      $this->resources[$locale] = vec[];
    }

    $this->resources[$locale][] = tuple($format, $resource, $domain);
    if (C\contains($this->fallbackLocales, $locale)) {
      $this->catalogues = dict[];
    } else {
      unset($this->catalogues[$locale]);
    }
  }

  /**
   * {@inheritdoc}
   */
  public function setLocale(string $locale): void {
    $this->assertValidLocale($locale);
    $this->locale = $locale;
  }

  /**
   * {@inheritdoc}
   */
  public function getLocale(): string {
    return $this->locale ?? \Locale::getDefault();
  }

  /**
   * Sets the fallback locales.
   *
   * @throws Exception\InvalidArgumentException If a locale contains invalid characters
   */
  public function setFallbackLocales(Container<string> $locales): void {
    // needed as the fallback locales are linked to the already loaded catalogues
    $this->catalogues = dict[];
    foreach ($locales as $locale) {
      $this->assertValidLocale($locale);
    }
    $this->fallbackLocales = vec($locales);
  }

  /**
   * {@inheritdoc}
   */
  public async function trans<<<__Enforceable>> reify T>(
    string $id,
    KeyedContainer<string, T> $parameters = dict[],
    ?string $locale = null,
    ?string $domain = null,
  ): Awaitable<string> {
    if ($domain is null) {
      $domain = 'messages';
    }

    $id = (string)$id;
    $catalogue = await $this->getCatalogue($locale);
    $locale = $catalogue->getLocale();
    while (!$catalogue->defines($id, $domain)) {
      $cat = $catalogue->getFallbackCatalogue();
      if ($cat is nonnull) {
        $catalogue = $cat;
        $locale = $catalogue->getLocale();
      } else {
        break;
      }
    }

    return await $this->formatter
      ->format<T>($catalogue->get($id, $domain), $locale, $parameters);
  }

  /**
   * {@inheritdoc}
   */
  public async function getCatalogue(
    ?string $locale = null,
  ): Awaitable<MessageCatalogue> {
    if ($locale is null) {
      $locale = $this->getLocale();
    } else {
      $this->assertValidLocale($locale);
    }

    if (!C\contains_key($this->catalogues, $locale)) {
      await $this->loadCatalogue($locale);
    }

    return $this->catalogues[$locale];
  }

  protected async function loadCatalogue(string $locale): Awaitable<void> {
    $this->assertValidLocale($locale);
    try {
      await $this->doLoadCatalogue($locale);
    } catch (Exception\NotFoundResourceException $e) {
      if (0 === C\count($this->computeFallbackLocales($locale))) {
        throw $e;
      }
    }

    await $this->loadFallbackCatalogues($locale);
  }

  /**
   * @internal
   */
  protected async function doLoadCatalogue(string $locale): Awaitable<void> {
    $this->catalogues[$locale] = new MessageCatalogue($locale);
    if (C\contains_key($this->resources, $locale)) {
      $lastOperation = async {
      };

      foreach ($this->resources[$locale] as $resource) {
        $lastOperation = async {
          await $lastOperation;
          list($format, $resource, $domain) = $resource;
          if (!C\contains_key($this->loaders, $format)) {
            throw new Exception\RuntimeException(Str\format(
              'The given resource of "%s" format has no registerd loader.',
              $format,
            ));
          }

          $loader = $this->loaders[$format];
          try {
            $catalogue = await $loader->load(
              TypeAssert\matches_type_structure(
                $loader->getFormat(),
                $resource,
              ),
              $locale,
              $domain,
            );
            $this->catalogues[$locale]->addCatalogue($catalogue);
          } catch (TypeAssert\IncorrectTypeException $e) {
            throw new Exception\InvalidResourceException(
              Str\format(
                'Loader for "%s" format was unable to load the given resource.',
                $format,
              ),
              $e->getCode(),
              $e,
            );
          }
        };
      }

      await $lastOperation;
    }
  }

  private async function loadFallbackCatalogues(
    string $locale,
  ): Awaitable<void> {
    $lastOperation = async {
      return $this->catalogues[$locale];
    };

    foreach ($this->computeFallbackLocales($locale) as $fallback) {
      $lastOperation = async {
        $current = await $lastOperation;
        if (!C\contains_key($this->catalogues, $fallback)) {
          await $this->loadCatalogue($fallback);
        }

        $fallbackCatalogue = new MessageCatalogue(
          $fallback,
          $this->getAllMessages($this->catalogues[$fallback]),
        );
        $current->addFallbackCatalogue($fallbackCatalogue);

        return $fallbackCatalogue;
      };
    }

    await $lastOperation;
  }

  protected function computeFallbackLocales(string $locale): Container<string> {
    $locales = vec[];
    foreach ($this->fallbackLocales as $fallback) {
      if ($fallback === $locale) {
        continue;
      }
      $locales[] = $fallback;
    }

    while ($locale is nonnull) {
      $parent = _Private\Parents[$locale] ?? null;
      if ($parent is null && Str\contains($locale, '_')) {
        $locale = Str\slice($locale, 0, Str\search_last($locale, '_'));
      } else if ('root' !== $parent) {
        $locale = $parent;
      } else {
        $locale = null;
      }

      if ($locale is nonnull) {
        $locales = Vec\concat(vec[$locale], $locales);
      }
    }

    return Vec\unique($locales);
  }

  /**
   * Asserts that the locale is valid, throws an Exception if not.
   *
   * @param string $locale Locale to tests
   *
   * @throws InvalidArgumentException If the locale contains invalid characters
   */
  protected function assertValidLocale(string $locale): void {
    if (!Regex\matches($locale, re"/^[a-z0-9@_\\.\\-]*$/i")) {
      throw new Exception\InvalidArgumentException(
        Str\format('Invalid "%s" locale.', $locale),
      );
    }
  }

  private function getAllMessages(
    MessageCatalogue $catalogue,
  ): KeyedContainer<string, KeyedContainer<string, string>> {
    $allMessages = dict[];
    foreach ($catalogue->all() as $domain => $messages) {
      if (0 !== C\count($messages)) {
        $allMessages[$domain] = $messages;
      }
    }
    return $allMessages;
  }
}
