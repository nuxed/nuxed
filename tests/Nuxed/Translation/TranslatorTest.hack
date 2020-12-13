namespace Nuxed\Test\Translation;

use namespace HH\Lib\Str;
use namespace Nuxed\Translation;
use namespace Nuxed\Translation\Exception;
use namespace Facebook\HackTest;
use function Facebook\FBExpect\expect;

class TranslatorTest extends HackTest\HackTest {
  <<HackTest\DataProvider('provideInvalidLocales')>>
  public function testConstructInvalidLocale(string $locale): void {
    expect(() ==> new Translation\Translator($locale))->toThrow(
      Exception\InvalidArgumentException::class,
    );
  }

  <<HackTest\DataProvider('provideValidLocales')>>
  public function testConstructValidLocale(string $locale): void {
    $translator = new Translation\Translator($locale);
    expect($translator->getLocale())
      ->toBeSame($locale);
  }

  public function testSetGetLocale(): void {
    $translator = new Translation\Translator('en');
    expect($translator->getLocale())->toBeSame('en');
    $translator->setLocale('fr');
    expect($translator->getLocale())->toBeSame('fr');
  }

  <<HackTest\DataProvider('provideInvalidLocales')>>
  public function testSetInvalidLocale(string $locale): void {
    $translator = new Translation\Translator('en');

    expect(() ==> $translator->setLocale($locale))->toThrow(
      Exception\InvalidArgumentException::class,
    );
  }

  <<HackTest\DataProvider('provideValidLocales')>>
  public function testSetValidLocale(string $locale): void {
    $translator = new Translation\Translator('en');
    $translator->setLocale($locale);
    expect($translator->getLocale())->toBeSame($locale);
  }

  public async function testGetCatalogue(): Awaitable<void> {
    $translator = new Translation\Translator('en');
    $catalogue = await $translator->getCatalogue();
    expect($catalogue->getLocale())->toBeSame('en');
    expect(dict($catalogue->all()))->toBeSame(dict[]);
    $translator->setLocale('fr');
    $catalogue = await $translator->getCatalogue();
    expect($catalogue->getLocale())->toBeSame('fr');
    expect(dict($catalogue->all()))->toBeSame(dict[]);
    $frCatalogue = await $translator->getCatalogue('fr');
    expect($frCatalogue)->toBeSame($catalogue);
  }

  public async function testGetCatalogueReturnsConsolidatedCatalogue(
  ): Awaitable<void> {
    /*
     * This will be useful once we refactor so that different domains will be loaded lazily (on-demand).
     * In that case, getCatalogue() will probably have to load all missing domains in order to return
     * one complete catalogue.
     */
    $locale = 'whatever';
    $translator = new Translation\Translator($locale);
    $translator->addLoader('tree', new Translation\Loader\TreeLoader());
    $translator->addLoader('ini', new Translation\Loader\IniFileLoader());

    $translator->addResource(
      'tree',
      dict['foo' => 'foofoo'],
      $locale,
      'domain-a',
    );
    $translator->addResource(
      'ini',
      __DIR__.'/fixtures/user.en.ini',
      $locale,
      'domain-b',
    );

    /*
     * Test that we get a single catalogue comprising messages
     * from different loaders and different domains
     */
    $catalogue = await $translator->getCatalogue($locale);
    expect($catalogue->defines('foo', 'domain-a'))->toBeTrue();
    expect($catalogue->defines('security.login.username', 'domain-b'))
      ->toBeTrue();
  }


  public async function testSetFallbackLocales(): Awaitable<void> {
    $translator = new Translation\Translator('en');
    $translator->addLoader('tree', new Translation\Loader\TreeLoader());
    $translator->addResource('tree', dict['foo' => 'foofoo'], 'en');
    $translator->addResource('tree', dict['bar' => 'foobar'], 'fr');
    // force catalogue loading
    await $translator->trans('bar');
    $translator->setFallbackLocales(vec['fr']);
    expect(await $translator->trans('bar'))->toBeSame('foobar');
  }


  public async function testSetFallbackLocalesMultiple(): Awaitable<void> {
    $translator = new Translation\Translator('en');
    $translator->addLoader('tree', new Translation\Loader\TreeLoader());
    $translator->addResource('tree', dict['foo' => 'foo (en)'], 'en');
    $translator->addResource('tree', dict['bar' => 'bar (fr)'], 'fr');
    // force catalogue loading
    await $translator->trans('bar');
    $translator->setFallbackLocales(vec['fr_FR', 'fr']);
    expect(await $translator->trans('bar'))->toBeSame('bar (fr)');
  }

  <<HackTest\DataProvider('provideInvalidLocales')>>
  public function testSetFallbackInvalidLocales(string $locale): void {
    $translator = new Translation\Translator('en');
    expect(() ==> $translator->setFallbackLocales(vec['en', $locale]))->toThrow(
      Exception\InvalidArgumentException::class,
    );
  }

  <<HackTest\DataProvider('provideValidLocales')>>
  public async function testSetFallbackValidLocales(
    string $locale,
  ): Awaitable<void> {
    $translator = new Translation\Translator('en');
    $translator->setFallbackLocales(vec['ar', $locale]);
    $catalogue = await $translator->getCatalogue();
    expect(
      $catalogue->getFallbackCatalogue()
        ?->getFallbackCatalogue()
        ?->getLocale(),
    )->toBeSame($locale);
  }

  public async function testTransWithFallbackLocale(): Awaitable<void> {
    $translator = new Translation\Translator('fr_FR');
    $translator->setFallbackLocales(vec['en']);
    $translator->addLoader('ini', new Translation\Loader\IniFileLoader());
    $translator->addResource('ini', __DIR__.'/fixtures/user.en.ini', 'en');
    expect(await $translator->trans('security.login.username'))->toBeSame(
      'Username',
    );
  }

  <<HackTest\DataProvider('provideInvalidLocales')>>
  public function testAddResourceInvalidLocales(string $locale): void {
    $translator = new Translation\Translator('fr');
    expect(
      () ==> $translator->addResource('tree', dict['foo' => 'foofoo'], $locale),
    )->toThrow(Exception\InvalidArgumentException::class);
  }

  <<HackTest\DataProvider('provideValidLocales')>>
  public function testAddResourceValidLocales(string $locale): void {
    $translator = new Translation\Translator('fr');
    $translator->addResource('tree', dict['foo' => 'foofoo'], $locale);
  }

  public function provideInvalidLocales(): Container<(string)> {
    return vec[
      tuple('fr FR'),
      tuple('français'),
      tuple('fr+en'),
      tuple('utf#8'),
      tuple('fr&en'),
      tuple('fr~FR'),
      tuple(' fr'),
      tuple('fr '),
      tuple('fr*'),
      tuple('fr/FR'),
      tuple('fr\\FR'),
    ];
  }

  public function provideValidLocales(): Container<(string)> {
    return vec[
      tuple(''),
      tuple('fr'),
      tuple('francais'),
      tuple('FR'),
      tuple('frFR'),
      tuple('fr-FR'),
      tuple('fr_FR'),
      tuple('fr.FR'),
      tuple('fr-FR.UTF8'),
      tuple('sr@latin'),
    ];
  }

  public async function testAddResourceAfterTrans(): Awaitable<void> {
    $translator = new Translation\Translator('fr');
    $translator->addLoader('tree', new Translation\Loader\TreeLoader());
    $translator->setFallbackLocales(vec['en']);
    $translator->addResource('tree', dict['foo' => 'foofoo'], 'en');
    expect(await $translator->trans('foo'))->toBeSame('foofoo');
    $translator->addResource('tree', dict['bar' => 'foobar'], 'en');
    expect(await $translator->trans('bar'))->toBeSame('foobar');
  }

  <<HackTest\DataProvider('provideTransFileTests')>>
  public function testTransWithoutFallbackLocaleFile(
    string $format,
    Translation\Loader\ILoader $loader,
    string $extension,
  ): void {
    $translator = new Translation\Translator('en');
    $translator->addLoader($format, $loader);
    $translator->addResource($format, __DIR__.'/fixtures/non-existing', 'en');
    $resource = Str\format('%s%s', __DIR__.'/fixtures/user.en.', $extension);
    $translator->addResource($format, $resource, 'en');
    // force catalogue loading
    expect(() ==> $translator->trans('foo'))->toThrow(
      Exception\NotFoundResourceException::class,
    );
  }

  <<HackTest\DataProvider('provideTransFileTests')>>
  public async function testTransWithFallbackLocaleFile(
    string $format,
    Translation\Loader\ILoader $loader,
    string $extension,
  ): Awaitable<void> {
    $translator = new Translation\Translator('en');
    $translator->addLoader($format, $loader);
    $translator->addResource($format, __DIR__.'/fixtures/non-existing', 'fr');
    $resource = Str\format('%s%s', __DIR__.'/fixtures/user.en.', $extension);
    $translator->addResource($format, $resource, 'en');
    expect(await $translator->trans('security.login.username', dict[], 'en'));
  }

  public function provideTransFileTests(
  ): Container<(string, Translation\Loader\ILoader, string)> {
    return vec[
      tuple('json', new Translation\Loader\JsonFileLoader(), 'json'),
      tuple('ini', new Translation\Loader\IniFileLoader(), 'ini'),
    ];
  }

  public async function testTransWithIcuFallbackLocale(): Awaitable<void> {
    $translator = new Translation\Translator('en_GB');
    $translator->addLoader('tree', new Translation\Loader\TreeLoader());
    $translator->addResource('tree', dict['foo' => 'foofoo'], 'en_GB');
    $translator->addResource('tree', dict['bar' => 'foobar'], 'en_001');
    $translator->addResource('tree', dict['baz' => 'foobaz'], 'en');
    expect(await $translator->trans('foo'))->toBeSame('foofoo');
    expect(await $translator->trans('bar'))->toBeSame('foobar');
    expect(await $translator->trans('baz'))->toBeSame('foobaz');
  }

  public async function testTransWithIcuVariantFallbackLocale(
  ): Awaitable<void> {
    $translator = new Translation\Translator('en_GB');
    $translator->addLoader('tree', new Translation\Loader\TreeLoader());
    $translator->addResource('tree', dict['bar' => 'foobar'], 'en_GB');
    $translator->addResource('tree', dict['baz' => 'foobaz'], 'en_001');
    $translator->addResource('tree', dict['qux' => 'fooqux'], 'en');

    expect(await $translator->trans('bar'))->toBeSame('foobar');
    expect(await $translator->trans('baz'))->toBeSame('foobaz');
    expect(await $translator->trans('qux'))->toBeSame('fooqux');
  }

  public async function testTransWithIcuRootFallbackLocale(): Awaitable<void> {
    $translator = new Translation\Translator('az_Cyrl');
    $translator->addLoader('tree', new Translation\Loader\TreeLoader());
    $translator->addResource('tree', dict['foo' => 'foofoo'], 'az_Cyrl');
    $translator->addResource('tree', dict['bar' => 'foobar'], 'az');
    expect(await $translator->trans('foo'))->toBeSame('foofoo');
    expect(await $translator->trans('bar'))->toBeSame('bar');
  }

  public async function testTransWithFallbackLocaleBis(): Awaitable<void> {
    $translator = new Translation\Translator('en_US');
    $translator->addLoader('tree', new Translation\Loader\TreeLoader());
    $translator->addResource('tree', dict['foo' => 'foofoo'], 'en_US');
    $translator->addResource('tree', dict['bar' => 'foobar'], 'en');
    expect(await $translator->trans('bar'))->toBeSame('foobar');
  }

  public async function testTransWithFallbackLocaleTer(): Awaitable<void> {
    $translator = new Translation\Translator('fr_FR');
    $translator->addLoader('tree', new Translation\Loader\TreeLoader());
    $translator->addResource('tree', dict['foo' => 'foo (en_US)'], 'en_US');
    $translator->addResource('tree', dict['bar' => 'bar (en)'], 'en');
    $translator->setFallbackLocales(vec['en_US', 'en']);
    expect(await $translator->trans('bar'))->toBeSame('bar (en)');
    expect(await $translator->trans('foo'))->toBeSame('foo (en_US)');
  }

  public async function testTransNonExistentWithFallback(): Awaitable<void> {
    $translator = new Translation\Translator('fr');
    $translator->setFallbackLocales(vec['en']);
    $translator->addLoader('tree', new Translation\Loader\TreeLoader());
    expect(await $translator->trans('non-existent'))->toBeSame('non-existent');
  }

  public function testWhenAResourceHasNoRegisteredLoader(): void {
    $translator = new Translation\Translator('en');
    $translator->addResource('tree', dict['foo' => 'foo'], 'en');
    expect(() ==> $translator->trans('foo'))->toThrow(
      Exception\RuntimeException::class,
    );
  }

  public async function testNestedFallbackCatalogueWhenUsingMultipleLocales(
  ): Awaitable<void> {
    $translator = new Translation\Translator('fr');
    $translator->setFallbackLocales(vec['ru', 'en']);
    $fr = await $translator->getCatalogue('fr');
    expect($fr->getFallbackCatalogue())->toNotBeNull();
    $ru = $fr->getFallbackCatalogue() as nonnull;
    expect($ru->getLocale())->toBeSame('ru');
    expect($ru->getFallbackCatalogue())->toNotBeNull();
    $en = $ru->getFallbackCatalogue() as nonnull;
    expect($en->getLocale())->toBeSame('en');
    expect($en->getFallbackCatalogue())->toBeNull();
  }

  <<HackTest\DataProvider('provideTransTests')>>
  public async function testTrans(
    string $expected,
    string $id,
    string $translation,
    KeyedContainer<string, arraykey> $parameters,
    string $locale,
    ?string $domain,
  ): Awaitable<void> {
    $translator = new Translation\Translator('en');
    $translator->addLoader('tree', new Translation\Loader\TreeLoader());
    $translator->addResource(
      'tree',
      dict[$id => $translation],
      $locale,
      $domain,
    );
    expect(await $translator->trans($id, $parameters, $locale, $domain))
      ->toBeSame($expected);
  }

  public function provideTransTests(
  ): Container<(
    string,
    string,
    string,
    KeyedContainer<string, arraykey>,
    ?string,
    ?string,
  )> {
    return vec[
      tuple(
        'Nuxed est super !',
        'Nuxed is great!',
        'Nuxed est super !',
        dict[],
        'fr',
        null,
      ),
      tuple(
        'Nuxed aime Symfony !',
        'Nuxed loves {what}!',
        'Nuxed aime {what} !',
        dict['what' => 'Symfony'],
        'fr',
        '',
      ),
      tuple(
        'Nuxed est super !',
        'Nuxed is great!',
        'Nuxed est super !',
        dict[],
        'fr',
        null,
      ),
    ];
  }

  <<HackTest\DataProvider('provideInvalidLocales')>>
  public function testTransInvalidLocale(string $locale): void {
    $translator = new Translation\Translator('en');
    $translator->addLoader('tree', new Translation\Loader\TreeLoader());
    $translator->addResource('tree', dict['foo' => 'foofoo'], 'en');
    expect(() ==> $translator->trans('foo', dict[], $locale))->toThrow(
      Exception\InvalidArgumentException::class,
    );
  }

  <<HackTest\DataProvider('provideValidLocales')>>
  public async function testTransValidLocale(string $locale): Awaitable<void> {
    $translator = new Translation\Translator($locale);
    $translator->addLoader('tree', new Translation\Loader\TreeLoader());
    $translator->addResource('tree', dict['test' => 'OK'], $locale);
    expect(await $translator->trans('test'))->toBeSame('OK');
    expect(await $translator->trans('test', dict[], $locale))->toBeSame('OK');
  }

  <<HackTest\DataProvider('provideFlattenedTransTests')>>
  public async function testFlattenedTrans(
    string $expected,
    KeyedContainer<string, mixed> $messages,
    string $id,
  ): Awaitable<void> {
    $translator = new Translation\Translator('en');
    $translator->addLoader('tree', new Translation\Loader\TreeLoader());
    $translator->addResource('tree', $messages, 'fr');
    expect(await $translator->trans($id, dict[], 'fr'))
      ->toBeSame($expected);
  }

  public function provideFlattenedTransTests(
  ): Container<(string, KeyedContainer<string, mixed>, string)> {
    $messages = dict[
      'nuxed' => dict['loves' => dict['symfony' => 'Nuxed loves Symfony <3']],
      'foo' => dict['bar' => dict['baz' => 'Foo Bar Baz'], 'baz' => 'Foo Baz'],
    ];

    return vec[
      tuple('Nuxed loves Symfony <3', $messages, 'nuxed.loves.symfony'),
      tuple('Foo Bar Baz', $messages, 'foo.bar.baz'),
      tuple('Foo Baz', $messages, 'foo.baz'),
    ];
  }


}
