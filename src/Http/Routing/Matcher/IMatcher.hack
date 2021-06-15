namespace Nuxed\Http\Routing\Matcher;

use namespace Nuxed\Http\{Message, Routing};

interface IMatcher {
  /**
   * Match a request against the known routes.
   */
  public function match(
    Message\IRequest $request,
  ): Awaitable<(Routing\Route, KeyedContainer<string, string>)>;
}
