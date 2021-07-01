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
 * Stack middleware like unix pipes.
 *
 * This interface represents a stack of middleware, which can be attached using
 * the `stack()` method, and is itself middleware.
 */
interface IMiddlewareStack extends IMiddleware {
  /**
   * Attach middleware to the stack.
   */
  public function stack(IMiddleware $middleware, int $priority = 0): this;
}
