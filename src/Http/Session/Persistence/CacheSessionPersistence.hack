/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Nuxed\Http\Session\Persistence;

use namespace HH\Lib\C;
use namespace Nuxed\{Cache, Json};
use namespace Facebook\TypeSpec;
use namespace Nuxed\Http\{Message, Session};

type ISessionCache = Cache\ICache;

/**
 * Session persistence using a cache item pool.
 *
 * Session identifiers are generated using random_bytes (and casting to hex).
 * During persistence, if the session regeneration flag is true, a new session
 * identifier is created, and the session re-started.
 */
final class CacheSessionPersistence extends AbstractSessionPersistence {
  public function __construct(
    private ISessionCache $cache,
    protected this::TCookieOptions $cookieOptions,
    protected ?Session\CacheLimiter $cacheLimiter,
    protected int $cacheExpire,
  ) {}

  <<__Override>>
  public async function initialize(
    Message\IServerRequest $request,
  ): Awaitable<Session\ISession> {
    $this->pathTranslated = (string)(
      $request->getServerParams()['PATH_TRANSLATED'] ?? ''
    );
    $id = $this->getCookieFromRequest($request);
    $sessionData = dict[];
    if ($id !== '') {
      $sessionData = await $this->getSessionDataFromCache($id);
    }

    return new Session\Session($sessionData, $id);
  }

  <<__Override>>
  public async function persist(
    Session\ISession $session,
    Message\IResponse $response,
  ): Awaitable<Message\IResponse> {
    $id = $session->getId();

    // New session? No data? Nothing to do.
    if (
      '' === $id &&
      (0 === C\count($session->items<mixed>()) || !$session->changed())
    ) {
      return $response;
    }

    if ($session->flushed()) {
      if ($id !== '') {
        $contains = await $this->cache->contains($id);
        if ($contains) {
          await $this->cache->forget($id);
        }
      }

      return $this->flush($session, $response);
    }

    // Regenerate the session if:
    // - we have no session identifier
    // - the session is marked as regenerated
    // - the session has changed (data is different)
    if ('' === $id || $session->regenerated() || $session->changed()) {
      $id = await $this->regenerateSession($id);
    }

    $age = $this->getPersistenceDuration($session);
    $items = Json\encode($session->items<mixed>());
    await $this->cache->put<string>($id, $items, $age);

    return $this->withCacheHeaders(
      $response->withCookie(
        $this->cookieOptions['name'],
        $this->createCookie($id, $age),
      ),
    );
  }

  /**
   * Regenerates the session.
   *
   * If the cache has an entry corresponding to `$id`, this deletes it.
   *
   * Regardless, it generates and returns a new session identifier.
   */
  private async function regenerateSession(string $id): Awaitable<string> {
    if ('' !== $id) {
      $contains = await $this->cache->contains($id);
      if ($contains) {
        await $this->cache->forget($id);
      }
    }

    return $this->generateSessionId();
  }

  private async function getSessionDataFromCache(
    string $id,
  ): Awaitable<KeyedContainer<string, mixed>> {
    if (!await $this->cache->contains($id)) {
      return dict[];
    }

    $data = await $this->cache->get<string>($id);

    return Json\spec($data, TypeSpec\dict(TypeSpec\string(), TypeSpec\mixed()));
  }
}
