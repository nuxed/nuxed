namespace Nuxed\Http\Router\Matcher;

use namespace Nuxed\Http\{Message, Router};

interface IRequestMatcher {
  /**
   * Match a request against the known routes.
   */
  public function match(Message\IRequest $request): Awaitable<Router\Route>;
}
