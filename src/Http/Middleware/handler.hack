namespace Nuxed\Http\Middleware;

use namespace Nuxed\Http\Handler;

/**
 * Handler Middleware Decorator.
 *
 * Decorate a request handler as middleware.
 *
 * When pulling handlers from a container, or creating pipelines, it's
 * simplest if everything is of the same type, so we do not need to worry
 * about varying execution based on type.
 *
 * To manage this, this function decorates request handlers as middleware, so that
 * they may be piped or routed to. When processed, they delegate handling to the
 * decorated handler, which will return a response.
 */
function handler(Handler\IHandler $handler): HandlerDecorator {
  return new HandlerDecorator($handler);
}
