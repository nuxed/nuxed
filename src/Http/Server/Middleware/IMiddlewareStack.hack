namespace Nuxed\Http\Server\Middleware;

/**
 * Stack middleware like unix pipes.
 *
 * This interface represents a stack of middleware, which can be attached using
 * the `stack()` method, and is itself middleware.
 */
interface IMiddlewareStack extends IMiddleware {
  /**
   * Attach middleware to the stack.
   */
  public function stack(IMiddleware $middleware, int $priority = 0): void;
}
