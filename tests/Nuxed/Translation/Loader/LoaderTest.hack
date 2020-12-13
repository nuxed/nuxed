namespace Nuxed\Test\Translation\Loader;

use namespace Facebook\HackTest;
use namespace Facebook\TypeAssert;
use namespace Nuxed\Translation\Loader;

use function Facebook\FBExpect\expect;

abstract class LoaderTest extends HackTest\HackTest {
  abstract protected function getLoader(): Loader\ILoader;

  <<HackTest\DataProvider('provideLoadData')>>
  public async function testLoad(
    mixed $resource,
    string $locale,
    string $domain,
    KeyedContainer<string, string> $expected,
  ): Awaitable<void> {
    $loader = $this->getLoader();
    $resource = TypeAssert\matches_type_structure(
      $loader->getFormat(),
      $resource,
    );

    $catalogue = await $loader->load($resource, $locale, $domain);
    expect($catalogue->getLocale())->toBeSame($locale);
    expect($catalogue->getDomains())->toContain($domain);
    expect($catalogue->all())
      ->toBeSame(dict[
        $domain => $expected,
      ]);
  }

  abstract public function provideLoadData(
  ): Container<(mixed, string, string, KeyedContainer<string, string>)>;
}
