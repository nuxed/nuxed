/*
 * This file is part of the Nuxed package.
 *
 * (c) Saif Eddin Gmati <azjezz@protonmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */



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
