namespace Nuxed\Http\Router\Matcher;

use namespace Nuxed\Http\{Message, Router};

final class RequestMatcher implements IRequestMatcher {
  public function __construct(private Resolver\Resolver $resolver) {
  }

  /**
   * Match a request against the known routes.
   */
  public async function match(
    Message\IRequest $request,
  ): Awaitable<Router\Route> {
    try {
      return $this->resolver->resolve($request);
    } catch (Router\Exception\NotFoundException $e) {
      $methods = $this->resolver->getAllowedMethods($request);
      if ($methods is null) {
        throw $e;
      }

      throw new Router\Exception\MethodNotAllowedException(
        $request->getMethod(),
        $methods,
      );
    }
  }
}
