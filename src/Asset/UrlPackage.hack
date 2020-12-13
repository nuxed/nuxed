namespace Nuxed\Asset;

use namespace HH\Lib\{C, Str};
/**
 * Package that adds a base URL to asset URLs in addition to a version.
 *
 * The package allows to use more than one base URLs in which case
 * it randomly chooses one for each asset; it also guarantees that
 * any given path will always use the same base URL to be nice with
 * HTTP caching mechanisms.
 *
 * When the request context is available, this package can choose the
 * best base URL to use based on the current request scheme:
 *
 *  * For HTTP request, it chooses between all base URLs;
 *  * For HTTPs requests, it chooses between HTTPs base URLs and relative protocol URLs
 *    or falls back to any base URL if no secure ones are available.
 */
final class UrlPackage extends Package {
  private vec<string> $baseUrls = vec[];
  private ?UrlPackage $sslPackage;

  /**
   * @param Container<string> $baseUrls Base asset URLs
   */
  public function __construct(
    Container<string> $baseUrls,
    VersionStrategy\IVersionStrategy $versionStrategy,
    ?Context\IContextProvider $contextProvider = null,
  ) {
    parent::__construct($versionStrategy, $contextProvider);

    if (C\is_empty($baseUrls)) {
      throw new Exception\LogicException(
        'You must provide at least one base URL.',
      );
    }

    foreach ($baseUrls as $baseUrl) {
      $this->baseUrls[] = Str\trim_right($baseUrl, '/');
    }

    $sslUrls = $this->getSslUrls($baseUrls);

    if (0 !== C\count($sslUrls) && $baseUrls !== $sslUrls) {
      $this->sslPackage = new self($sslUrls, $versionStrategy);
    }
  }

  /**
   * {@inheritdoc}
   */
  <<__Override>>
  public async function getUrl(string $path): Awaitable<string> {
    if ($this->isAbsoluteUrl($path)) {
      return $path;
    }

    if ($this->getContext()->isSecure() && $this->sslPackage is nonnull) {
      return await $this->sslPackage->getUrl($path);
    }

    $url = await $this->getVersionStrategy()->applyVersion($path);

    if ($this->isAbsoluteUrl($url)) {
      return $url;
    }

    if (!Str\is_empty($url) && !Str\starts_with($url, '/')) {
      $url = '/'.$url;
    }

    return (await $this->getBaseUrl($path)).$url;
  }

  /**
   * Returns the base URL for a path.
   */
  public async function getBaseUrl(string $path): Awaitable<string> {
    if (1 === C\count($this->baseUrls)) {
      return $this->baseUrls[0];
    }

    return $this->baseUrls[await $this->chooseBaseUrl($path)];
  }

  /**
   * Determines which base URL to use for the given path.
   *
   * Override this method to change the default distribution strategy.
   * This method should always return the same base URL index for a given path.
   *
   * @return int The base URL index for the given path
   */
  protected async function chooseBaseUrl(string $path): Awaitable<int> {
    return (int)\fmod(
      (float)\hexdec(Str\slice(\hash('sha256', $path), 0, 10)),
      (float)C\count($this->baseUrls),
    );
  }

  private function getSslUrls(Container<string> $urls): vec<string> {
    $urls = vec<string>($urls);
    $sslUrls = vec[];
    foreach ($urls as $i => $url) {
      if (Str\starts_with($url, '//')) {
        $url = Str\format('https:%s', $url);
      }

      $schema = \parse_url($url, \PHP_URL_SCHEME) as ?string;
      if ($schema is null) {
        throw new Exception\InvalidArgumentException(
          Str\format('"%s" is not a valid URL', $url),
        );
      }

      if ('https' === Str\lowercase($schema)) {
        $sslUrls[] = $urls[$i];
      }
    }

    return $sslUrls;
  }
}
