namespace Nuxed\Http\Middleware;

/**
 * Create a middleware stack using the given middleware.
 *
 * @see IMiddlewareStack
 */
function stack(IMiddleware ...$middleware): IMiddlewareStack {
  $stack = new MiddlewareStack();
  foreach ($middleware as $mw) {
    $stack->stack($mw);
  }

  return $stack;
}
